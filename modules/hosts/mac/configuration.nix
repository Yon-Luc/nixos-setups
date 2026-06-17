{self, ...}: {
  flake.nixosModules.macConfiguration = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.macHardware
      self.nixosModules.settingsDefault
      self.nixosModules.packagesDefault
      self.nixosModules.cursor
      self.nixosModules.moonlight
    ];

    programs.moonlight.enable = true;

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

    networking.hostName = "mac";

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
    services.displayManager.defaultSession = "plasma";
    services.desktopManager.plasma6.enable = true;

    services.xserver.xkb = {
      layout = "fr";
      variant = "mac";
    };

    security.rtkit.enable = true;

    users.users.yonluc = {
      isNormalUser = true;
      description = "yonmac";
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };

    users.users.caroline = {
      isNormalUser = true;
      description = "caroline";
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        maestral
        maestral-gui
      ];
    };

    system.activationScripts.yonlucUsKeyboard = lib.mkAfter ''
      if [ -d /home/yonluc ]; then
        mkdir -p /home/yonluc/.config
        echo '[Layout]' > /home/yonluc/.config/kxkbrc
        echo 'LayoutList=us' >> /home/yonluc/.config/kxkbrc
        echo 'Use=true' >> /home/yonluc/.config/kxkbrc
        chown yonluc:users /home/yonluc/.config/kxkbrc
      fi
    '';

    nixpkgs.config.permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-59-6.18.33"
      "broadcom-sta-6.30.223.271-59-6.18.26"
      "broadcom-sta-6.30.223.271-59-6.18.20"
    ];

    system.stateVersion = "25.11";
  };
}
