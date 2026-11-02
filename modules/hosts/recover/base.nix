{self, ...}: {
  # Shared base for portable recovery profiles.
  # Filesystems use LABEL=nixos / LABEL=boot to match docs/RECOVER.md partitioning.
  # No machine-specific UUIDs, NICs, or GPU — specialize after first boot if needed.
  flake.nixosModules.recoverBase = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      self.nixosModules.settingsDefault
      self.nixosModules.packagesDefault
      self.nixosModules.homelabCache
    ];

    # Offline / unknown-hardware first; Tailscale needs a control plane.
    services.tailscale.enable = lib.mkForce false;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Broad enough for most x86_64 boxes; real hw-config can narrow later.
    boot.initrd.availableKernelModules = [
      "nvme"
      "ahci"
      "xhci_pci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sr_mod"
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"
      "ata_piix"
      "ehci_pci"
    ];
    boot.kernelModules = ["kvm-amd" "kvm-intel"];

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];

    networking.useDHCP = lib.mkDefault true;
    networking.wireless.enable = lib.mkForce false;
    networking.networkmanager.enable = true;
    networking.firewall.allowedTCPPorts = [22];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "prohibit-password";
    services.openssh.settings.PasswordAuthentication = false;

    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.xserver.xkb.layout = "us";
    security.rtkit.enable = true;
    programs.firefox.enable = true;

    users.users.yonluc = {
      isNormalUser = true;
      description = "Yonluc";
      extraGroups = ["networkmanager" "wheel" "video" "input"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt8iwH+omLlGX+Nbujwy0EEvf2S4MrX5Ex0pF1h/AUA yonluc@yont2"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDntZAQCEs41o671UG48CKM6dgnq8al9fYClbgV/9H1gKsjxFzfEuQrIkMocW6cn4SVUdZvUJ8CSz7fTAVJ259dHv/t3IkyogvDmVn2/hgfAMK3/xxVQ0bMpM3wd7OQyGfQfuypOuY2uSIgiqYpsFjVdC4EXtcQvG6oUEkI4fNwwAkpugsDi6RdCf+MxJsc3sbg/dNMuU2cTxNljG5QBQBFlnNtD8+Bv87CT3dvGHOS9f/EH7RuAWbOHCA1O3FRmQ6aCsKNiPxXgYW2O7dMO5YfdbuuoEbx7rb/vVyxs2yhyNUFYrYDhyYLVgSs1MOMRXsNIMWtJZt8jwh00JPcN39A4gArWiYxlGDVOhk/yujrU32LK7Kz2OMYK0UArfo5Kl07HiRmqEQgRnYECPEhEUfk3EQMBV/lDFvU3o8yROgpb65SPMnPiIPKCNDCp/tZUn6VdgOSvuvWgr2Q3JpTJGd5XBSarbyW4LU8rR+F0QgDSvBJcnNxtBanhHT+zGOg0v0= lukin@DESKTOP-LT5L083"
      ];
      packages = with pkgs; [kdePackages.kate];
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDntZAQCEs41o671UG48CKM6dgnq8al9fYClbgV/9H1gKsjxFzfEuQrIkMocW6cn4SVUdZvUJ8CSz7fTAVJ259dHv/t3IkyogvDmVn2/hgfAMK3/xxVQ0bMpM3wd7OQyGfQfuypOuY2uSIgiqYpsFjVdC4EXtcQvG6oUEkI4fNwwAkpugsDi6RdCf+MxJsc3sbg/dNMuU2cTxNljG5QBQBFlnNtD8+Bv87CT3dvGHOS9f/EH7RuAWbOHCA1O3FRmQ6aCsKNiPxXgYW2O7dMO5YfdbuuoEbx7rb/vVyxs2yhyNUFYrYDhyYLVgSs1MOMRXsNIMWtJZt8jwh00JPcN39A4gArWiYxlGDVOhk/yujrU32LK7Kz2OMYK0UArfo5Kl07HiRmqEQgRnYECPEhEUfk3EQMBV/lDFvU3o8yROgpb65SPMnPiIPKCNDCp/tZUn6VdgOSvuvWgr2Q3JpTJGd5XBSarbyW4LU8rR+F0QgDSvBJcnNxtBanhHT+zGOg0v0= lukin@DESKTOP-LT5L083"
    ];

    # After install: nixos-generate-config --show-hardware-config and fold into a real host.
    environment.etc."recover-profile-readme".text = ''
      Portable recovery profile. Partition with LABEL=nixos + LABEL=boot (see RECOVER.md).
      On first boot, prefer this only as a bridge: collect lspci/lsblk and create a real host config.
    '';

    system.stateVersion = "25.05";
  };
}
