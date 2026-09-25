{...}: {
  flake.nixosModules.settingsDefault = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

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
