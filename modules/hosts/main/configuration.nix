{self, ...}: {
  flake.nixosModules.mainConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.mainHardware
      self.nixosModules.settingsDefault
      self.nixosModules.cursor
      self.nixosModules.packagesDefault
      self.nixosModules.developmentDefault
      self.nixosModules.gamesDefault
      self.nixosModules.niri
      self.nixosModules.nixBuilder
      self.nixosModules.maestro-studio
    ];

    programs.maestro-studio.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    systemd.network.networks."10-enp12s0" = {
      matchConfig.Name = "enp12s0";
      linkConfig.EEE = false;
      linkConfig.Advertise = ["1000baseT-full"];
      linkConfig.AutoNegotiation = false;
    };

    boot.kernelParams = ["amdgpu.audio=1"];

    services.xserver.enable = true;

    services.displayManager.defaultSession = "niri";
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    security.rtkit.enable = true;

    users.users.yonluc = {
      isNormalUser = true;
      description = "Yonluc";

      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];

      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];

      extraGroups = [
        "networkmanager"
        "wheel"
        "podman"
        "input"
        "openrazer"
      ];

      packages = with pkgs; [
        kdePackages.kate
      ];
    };
    programs.firefox.enable = true;

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

    systemd.services = {
      nvidia-suspend = {
        enable = true;
        wantedBy = ["suspend.target"];
      };
      nvidia-hibernate = {
        enable = true;
        wantedBy = ["hibernate.target"];
      };
      nvidia-resume = {
        enable = true;
        wantedBy = ["resume.target" "hybrid-sleep.target"];
      };
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16 * 1024;
      }
    ];

    services.hardware.openrgb.enable = true;

    networking = {
      hostName = "main";
      wireless.enable = true;

      interfaces = {
        enp12s0 = {
          wakeOnLan.enable = true;
        };
      };

      networkmanager = {
        enable = true;
        wifi.powersave = false;
        wifi.macAddress = "permanent";
      };

      firewall = {
        allowedUDPPorts = [9];
        allowedTCPPorts = [24800 8081 19000 19001 19006 22 3000 3306 3307 6379 3010 47990];
      };
    };

    system.stateVersion = "25.05";
  };
}
