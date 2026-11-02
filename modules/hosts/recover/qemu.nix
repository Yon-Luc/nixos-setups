{self, inputs, ...}: {
  # QEMU/UEFI guest profile for Phase 8 disk-boot proofs (no NVIDIA).
  flake.nixosModules.recoverQemuConfiguration = {
    modulesPath,
    ...
  }: {
    imports = [
      self.nixosModules.recoverBase
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    networking.hostName = "recover-qemu";

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = ["modesetting"];
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
  };

  flake.nixosConfigurations.recover-qemu = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.recoverQemuConfiguration];
  };
}
