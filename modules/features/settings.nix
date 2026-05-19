{...}: {
  flake.nixosModules.settingsDefault = {...}: {
    nixpkgs.config.allowUnfree = true;
    environment.variables = {
      TERMINAL = "alacritty";
    };
    services.openssh.enable = true;
    services.tailscale.enable = true;

    programs.firefox.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    services.pulseaudio.enable = false;

    services.printing.enable = false;

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
