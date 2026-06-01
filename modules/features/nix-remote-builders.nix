{...}: {
  flake.nixosModules.nixRemoteBuilders = {
    config,
    lib,
    ...
  }: let
    cfg = config.nix-remote-builders;
  in {
    options.nix-remote-builders = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "main";
        description = ''
          SSH hostname for the remote Nix builder.
          Use a name that resolves on this machine (Tailscale MagicDNS, LAN IP, or /etc/hosts).
          Run `tailscale status` on yont2 and use the builder's DNS name or 100.x address.
        '';
      };
    };

    config = {
      nix.distributedBuilds = true;

      nix.buildMachines = [
        {
          hostName = cfg.host;
          systems = ["x86_64-linux"];
          maxJobs = 8;
          speedFactor = 2;
          sshUser = "yonluc";
          sshKey = "/etc/nix/ssh-keys/nix-builder-main";
          supportedFeatures = ["big-parallel" "kvm"];
        }
      ];

      nix.settings.builders-use-substitutes = true;

      programs.ssh.extraConfig = ''
        Host ${cfg.host}
          IdentityFile /etc/nix/ssh-keys/nix-builder-main
          IdentitiesOnly yes
          StrictHostKeyChecking accept-new
      '';
    };
  };
}
