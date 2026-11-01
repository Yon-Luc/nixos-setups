{inputs, ...}: {
  flake.nixosModules.hex = {
    imports = [inputs.hex.nixosModules.hex];
  };
}
