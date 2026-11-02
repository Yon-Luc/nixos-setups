{...}: {
  # LAN Harmonia cache client + upload helpers (desktop + recovery profiles).
  flake.nixosModules.homelabCache = {
    lib,
    pkgs,
    ...
  }: let
    cacheHost = "192.168.1.114";
    cachePubKey = "homelab-cache-1:K/VHeOl1YJsyXeaVSwY+pa2P/y4lYI5D6LTySQab0ZY=";
    cacheHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBo3bP+8ST6t95Rrpz916rhkzTcghFu5m+30aNxsMbA7";

    pushBody = ''
      CACHE_HOST="${cacheHost}"
      FLAKE_DIR="''${FLAKE_DIR:-/home/yonluc/nixos-setups}"
      REV="$(git -C "$FLAKE_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
      DATE="$(date -u +%F)"
      HASH="$(basename "$SYS" | cut -c1-8)"
      ROOT_NAME="''${PREFIX}-''${DATE}-''${REV}-''${HASH}"

      echo "Pushing $SYS → ssh-ng://cache-push@''${CACHE_HOST}"
      export NIX_SSHOPTS="-i /home/yonluc/.ssh/id_ed25519_cache_push -o IdentitiesOnly=yes"
      nix copy --to "ssh-ng://cache-push@''${CACHE_HOST}" "$SYS"

      echo "Verifying Harmonia can see the toplevel…"
      nix path-info --store "http://''${CACHE_HOST}:5000" "$SYS"

      echo "Creating GC root ''${ROOT_NAME} on cache…"
      ssh -o IdentitiesOnly=yes root@"''${CACHE_HOST}" \
        /run/current-system/sw/bin/root-closure.sh "$SYS" "$ROOT_NAME"

      echo "Rotating ''${PREFIX} GC roots…"
      ssh -o IdentitiesOnly=yes root@"''${CACHE_HOST}" \
        /run/current-system/sw/bin/rotate-cache-roots.sh "$PREFIX"

      echo "Exporting to static recovery cache on HDD…"
      ssh -o IdentitiesOnly=yes root@"''${CACHE_HOST}" \
        /run/current-system/sw/bin/export-static-cache.sh "$SYS"

      echo "OK: $SYS is on the live cache, rooted as ''${ROOT_NAME}, and on /mnt/recovery/cache."
    '';

    pushSystem = pkgs.writeShellApplication {
      name = "ncache";
      runtimeInputs = [pkgs.nix pkgs.coreutils pkgs.openssh pkgs.git];
      text = ''
        set -euo pipefail
        PREFIX=desktop
        SYS="$(readlink -f /run/current-system)"
        ${pushBody}
      '';
    };

    pushProfile = pkgs.writeShellApplication {
      name = "ncache-profile";
      runtimeInputs = [pkgs.nix pkgs.coreutils pkgs.openssh pkgs.git];
      text = ''
        set -euo pipefail

        if [[ $# -lt 1 ]]; then
          echo "usage: ncache-profile <flake-attr>" >&2
          echo "  examples:" >&2
          echo "    ncache-profile recover-generic" >&2
          echo "    ncache-profile recover-nvidia" >&2
          echo "    ncache-profile recover-qemu" >&2
          exit 2
        fi

        ATTR=$1
        # Root prefix must match flake attr (recover-generic, etc.).
        PREFIX=$ATTR
        FLAKE_DIR="''${FLAKE_DIR:-/home/yonluc/nixos-setups}"

        echo "Building nixosConfigurations.''${ATTR}…"
        SYS="$(nix build --no-link --print-out-paths \
          "''${FLAKE_DIR}#nixosConfigurations.''${ATTR}.config.system.build.toplevel")"

        ${pushBody}
      '';
    };
  in {
    nix.settings = {
      # Prefer the LAN cache; keep cache.nixos.org via the NixOS default merge.
      substituters = lib.mkBefore ["http://${cacheHost}:5000"];
      trusted-public-keys = [cachePubKey];
      connect-timeout = 5;
      fallback = true;
    };

    programs.ssh.knownHosts."${cacheHost}" = {
      publicKey = cacheHostKey;
    };

    # Dedicated alias only — do not bind User/IdentityFile to the raw IP
    # (deploy-rs / root SSH still use 192.168.1.114 directly).
    programs.ssh.extraConfig = ''
      Host cache-push
        HostName ${cacheHost}
        User cache-push
        IdentityFile /home/yonluc/.ssh/id_ed25519_cache_push
        IdentitiesOnly yes
    '';

    environment.systemPackages = [pushSystem pushProfile];
  };
}
