{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.yont2 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.yont2Configuration
    ];
  };
}
