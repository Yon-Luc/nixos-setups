{self, ...}: {
  flake.nixosModules.mainConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.mainHardware
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";
    networking.wireless.enable = true;
    networking.networkmanager.wifi.powersave = false;
    networking.networkmanager.wifi.macAddress = "permanent";

    environment.variables = {
      TERMINAL = "alacritty";
    };

    systemd.network.networks."10-enp12s0" = {
      matchConfig.Name = "enp12s0";
      linkConfig.EEE = false;
      linkConfig.Advertise = ["1000baseT-full"];
      linkConfig.AutoNegotiation = false;
    };

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

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    # Optional: Bluetooth GUI manager
    services.blueman.enable = true;

    nixpkgs.overlays = [
      (import ./overlays/osu-override.nix)
    ];

    services.printing.enable = false;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    users.users.yonluc = {
      isNormalUser = true;
      description = "Yonluc";
      extraGroups = ["networkmanager" "wheel" "podman" "input"];
      packages = with pkgs; [
        kdePackages.kate
        kdePackages.wacomtablet
      ];
    };

    programs.firefox.enable = true;

    nixpkgs.config.allowUnfree = true;

    services.xserver.videoDrivers = ["nvidia"];

    hardware.graphics = {
      enable = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
    };

    systemd.services.nvidia-suspend = {
      enable = true;
      wantedBy = ["suspend.target"];
    };
    systemd.services.nvidia-hibernate = {
      enable = true;
      wantedBy = ["hibernate.target"];
    };
    systemd.services.nvidia-resume = {
      enable = true;
      wantedBy = ["resume.target" "hybrid-sleep.target"];
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    nixpkgs.config.permittedInsecurePackages = ["beekeeper-studio-5.5.7" "ventoy-1.1.10"];

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16 * 1024;
      }
    ];

    #services.flatpak.enable = true;

    environment.systemPackages = with pkgs; [
      cypress
      lsof
      fastfetch
      macchina
      tcpdump
      xdotool
      wmctrl
      opencode
      steam
      git
      tree
      jq
      htop
      curl
      wget
      fastfetch
      gh
      pavucontrol
      chromium
      btop
      tmux
      pnpm
      beekeeper-studio
      input-leap
      bruno
      caligula
      ethtool
      unzip
      yt-dlp
      devtoolbox
      vlc
      vscodium
      wootility
      wooting-udev-rules
      podman-compose
      podman-desktop
      kubectl
      nodejs_24
      android-studio
      pear-desktop
      fuzzel
      openssh
      nmap
      zsh
      vim
      code-cursor-fhs
      alacritty
      obs-studio
      osu-lazer-bin
      vesktop
      wine
      (callPackage ./nixpkgs/ankama.nix {})
      bun
      glibc
      zig
      p7zip
      signal-desktop
      go
      winetricks
    ];

    services.hardware.openrgb.enable = true;

    hardware.wooting.enable = true;

    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    services.openssh.enable = true;

    services.tailscale.enable = true;

    networking = {
      interfaces = {
        enp12s0 = {
          wakeOnLan.enable = true;
        };
      };
      firewall = {
        allowedUDPPorts = [9];
      };
    };

    networking.firewall.allowedTCPPorts = [24800 8081 19000 19001 19006 22 3000 3306 3307 6379 3010];

    system.stateVersion = "25.05";
  };
}
