{self, ...}: {
  flake.nixosModules.macConfiguration = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.macHardware
      self.nixosModules.settingsDefault
      self.nixosModules.niri
      self.nixosModules.packagesDefault
      self.nixosModules.cursor
    ];
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    swapDevices = [
      {
        device = "/swapfile";
        size = 4096;
      }
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    programs.niri.enable = true;

    networking.hostName = "nixos-mac";

    networking.networkmanager.enable = true;

    hardware.enableRedistributableFirmware = true;

    boot.kernelModules = ["wl"];

    boot.extraModulePackages = with config.boot.kernelPackages; [
      broadcom_sta
    ];

    boot.blacklistedKernelModules = [
      "bcma"
      "b43"
      "brcmsmac"
      "ssb"
    ];

    services.xserver.enable = true;

    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    security.rtkit.enable = true;

    users.users.yonmac = {
      isNormalUser = true;
      description = "yonmac";
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };

    nixpkgs.config.permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-59-6.18.26"
      "broadcom-sta-6.30.223.271-59-6.18.20"
    ];

    system.stateVersion = "25.11";
  };
}
