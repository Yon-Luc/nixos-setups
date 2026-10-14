{...}: {
  flake.nixosModules.settingsDefault = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    # KWin 6.7.6 is not in nixpkgs yet (scheduled 2026-11-03). This is the
    # Plasma/6.7 backport of the Wine/Xwayland focus fix:
    # https://invent.kde.org/plasma/kwin/-/commit/ef6fa8354d428dcaf8a92841f77fd96cccfa2c11
    # BUG: https://bugs.kde.org/show_bug.cgi?id=525590
    nixpkgs.overlays = [
      (final: prev: {
        kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
          kwin = kdePrev.kwin.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              ./kwin-525590.patch
            ];
          });
        });
      })
    ];

    environment.variables = {
      TERMINAL = "ghostty";
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    environment.shellAliases = {
      ns = "sudo nixos-rebuild switch --flake ~/nixos-setups#$(hostname)";
      nt = "sudo nixos-rebuild test --flake ~/nixos-setups#$(hostname)";
      nb = "sudo nixos-rebuild build --flake ~/nixos-setups#$(hostname)";
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      kdePackages.kwallet
      kdePackages.kwallet-pam
      kdePackages.kwalletmanager
    ];

    security.pam.services.sddm.kwallet.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];

      config = {
        common = {
          default = ["kde" "gtk"];
        };
      };
    };

    services = {
      openssh.enable = true;
      tailscale.enable = true;
      blueman.enable = true;
      pulseaudio.enable = false;
      printing.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];
    time.timeZone = "Europe/Lisbon";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.UTF-8";
      LC_IDENTIFICATION = "pt_PT.UTF-8";
      LC_MEASUREMENT = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_NAME = "pt_PT.UTF-8";
      LC_NUMERIC = "pt_PT.UTF-8";
      LC_PAPER = "pt_PT.UTF-8";
      LC_TELEPHONE = "pt_PT.UTF-8";
      LC_TIME = "pt_PT.UTF-8";
    };
  };
}
