{self, inputs, ...}: {
  # Mesa / modesetting — best default for unknown or "weird" x86_64 PCs.
  flake.nixosModules.recoverGenericConfiguration = {...}: {
    imports = [self.nixosModules.recoverBase];

    networking.hostName = "recover-generic";

    hardware.graphics.enable = true;
    # Kernel modesetting + Mesa; works on Intel, AMD, and many NVIDIA (nouveau).
    services.xserver.videoDrivers = ["modesetting"];
  };

  flake.nixosConfigurations.recover-generic = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.recoverGenericConfiguration];
  };
}
