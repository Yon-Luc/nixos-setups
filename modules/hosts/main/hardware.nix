{...}: {
  flake.nixosModules.mainHardware = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod"];
    boot.initrd.kernelModules = ["8821cu"];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [config.boot.kernelPackages.rtl8821cu];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/daa89d87-afcb-49e1-9865-5c81d8d999e9";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/BC91-CD93";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
