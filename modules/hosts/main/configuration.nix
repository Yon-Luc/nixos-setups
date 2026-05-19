{self, ...}: {
  flake.nixosModules.mainConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.mainHardware
      self.nixosModules.settingsDefault
      self.nixosModules.cursor
      self.nixosModules.packagesDefault
      self.nixosModules.developmentDefault
      self.nixosModules.gamesDefault
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";
    networking.wireless.enable = true;
    networking.networkmanager.wifi.powersave = false;
    networking.networkmanager.wifi.macAddress = "permanent";

    systemd.network.networks."10-enp12s0" = {
      matchConfig.Name = "enp12s0";
      linkConfig.EEE = false;
      linkConfig.Advertise = ["1000baseT-full"];
      linkConfig.AutoNegotiation = false;
    };

    networking.networkmanager.enable = true;

    services.xserver.enable = true;

    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Optional: Bluetooth GUI manager

    security.rtkit.enable = true;

    users.users.yonluc = {
      isNormalUser = true;
      description = "Yonluc";
      extraGroups = ["networkmanager" "wheel" "podman" "input"];
      packages = with pkgs; [
        kdePackages.kate
        kdePackages.wacomtablet
      ];
    };

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

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16 * 1024;
      }
    ];

    services.hardware.openrgb.enable = true;

    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

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
