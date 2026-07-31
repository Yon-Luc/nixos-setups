{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.yont2Configuration = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.yont2Hardware
      self.nixosModules.yont2Substituter
      inputs.nixos-hardware.nixosModules.apple-t2
      inputs.t2fanrd.nixosModules.t2fanrd
      self.nixosModules.settingsDefault
      self.nixosModules.packagesDefault
      self.nixosModules.developmentDefault
      self.nixosModules.niri
      self.nixosModules.cursor
      self.nixosModules.moonlight
      self.nixosModules.nixRemoteBuilders
    ];

    networking.hosts."main" = ["100.110.35.84"];

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

    environment.systemPackages = [
      pkgs.mgba
      pkgs.vscodium-fhs
      pkgs.vscode-fhs
    ];

    # Two fans on APP0001:00; t2fanrd uses Fan1/Fan2 (not lm_sensors' fan1/fan2).
    services.t2fanrd = {
      enable = true;
      config = {
        Fan1 = {
          low_temp = 48;
          high_temp = 75;
          speed_curve = "linear";
          always_full_speed = false;
        };
        Fan2 = {
          low_temp = 48;
          high_temp = 75;
          speed_curve = "linear";
          always_full_speed = false;
        };
      };
    };

    services.upower.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";

    # nixos-hardware apple-t2 "latest" still pins EOL linux_7_0; use 7.1 + t2linux 7.1 patches.
    boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (
      pkgs.callPackage "${inputs.nixos-hardware}/apple/t2/pkgs/linux-t2/generic.nix" {} {
        kernel = pkgs.linux_7_1;
        patchesFile = ./linux-t2-7.1.json;
      }
    ));

    # MacBookPro15,1: force Intel iGPU so AMD dGPU doesn't break suspend/resume.
    hardware.apple-t2.enableIGPU = true;

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
