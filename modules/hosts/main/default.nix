{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.main = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {nixpkgs.config.allowUnfree = true;}
      self.nixosModules.mainConfiguration
    ];
  };
}
