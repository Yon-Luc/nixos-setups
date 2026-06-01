{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.yont2Configuration = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.yont2Hardware
      self.nixosModules.yont2Substituter
      inputs.nixos-hardware.nixosModules.apple-t2
      self.nixosModules.settingsDefault
      self.nixosModules.packagesDefault
      self.nixosModules.developmentDefault
      self.nixosModules.niri
      self.nixosModules.cursor
      self.nixosModules.moonlight
      self.nixosModules.nixRemoteBuilders
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
    boot.loader.efi.efiSysMountPoint = "/boot";

    hardware.enableRedistributableFirmware = true;

    hardware.firmware = [
      (pkgs.stdenvNoCC.mkDerivation (final: {
        name = "brcm-firmware";
        src = /etc/nixos/brcm;
        installPhase = ''
          mkdir -p $out/lib/firmware/brcm
          cp ${final.src}/* "$out/lib/firmware/brcm"
        '';
      }))
    ];

    networking.hostName = "yont2";
    networking.networkmanager.enable = true;

    programs.niri.enable = true;

    services.xserver.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.displayManager.defaultSession = "niri";

    services.xserver.xkb = {
      layout = "us";
      options = "eurosign:e,caps:escape";
    };

    services.libinput.enable = true;

    security.rtkit.enable = true;

    users.users.yonluc = {
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        tree
      ];
    };

    system.stateVersion = "25.11";
  };
}
