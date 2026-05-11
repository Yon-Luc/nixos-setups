{ self, inputs, ... }: {
  flake.nixosConfigurations.mac = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.macConfiguration
    ];
  };
}
