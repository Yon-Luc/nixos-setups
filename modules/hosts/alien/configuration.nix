{self, ...}: {
  flake.nixosModules.alienConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.alienHardware
      self.nixosModules.niri
    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";

    networking.networkmanager.enable = true;

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

    services.xserver.enable = true;

    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = false;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia.open = true;
    hardware.nvidia.modesetting.enable = true;

    users.users.yonluc = {
      isNormalUser = true;
      description = "yonluc";
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };

    programs.firefox.enable = true;

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      #  wget
      git
      wooting-udev-rules
      vesktop
      wootility
      bottles
      chromium
      osu-lazer-bin
      vscodium-fhs
      bun
      nodejs_25
      btop
      alacritty
      nmap
    ];

    system.stateVersion = "25.11";
  };
}
