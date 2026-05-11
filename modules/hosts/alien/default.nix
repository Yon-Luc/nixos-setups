{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.alien = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.alienConfiguration
    ];
  };
}
