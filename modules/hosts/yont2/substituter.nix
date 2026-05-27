{...}: {
  flake.nixosModules.yont2Substituter = {...}: let
    substituters = ["https://cache.soopy.moe"];
  in {
    nix.settings = {
      inherit substituters;
      trusted-substituters = substituters;
      trusted-public-keys = ["cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="];
    };
  };
}
