{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # noctalia v4 (noctalia-shell) was removed from nixpkgs on 2026-10-22.
    # v5 does not read the existing JSON config or the Niri IPC commands.
    nixpkgs-noctalia-shell = {
      url = "github:NixOS/nixpkgs/02c087f3fe673c9e317f206a627cb6b910336dbe";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    t2fanrd = {
      url = "github:GnomedDev/T2FanRD";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hex = {
      url = "github:anomalyco/hex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
