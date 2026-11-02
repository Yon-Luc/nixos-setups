{self, inputs, ...}: {
  # Same portable base with proprietary NVIDIA (open module).
  # Use when the target needs the NVIDIA stack and modesetting/nouveau is not enough.
  flake.nixosModules.recoverNvidiaConfiguration = {...}: {
    imports = [self.nixosModules.recoverBase];

    networking.hostName = "recover-nvidia";

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
    };
  };

  flake.nixosConfigurations.recover-nvidia = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.recoverNvidiaConfiguration];
  };
}
