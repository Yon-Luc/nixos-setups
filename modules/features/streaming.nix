{self, ...}: {
  flake.nixosModules.moonlight = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.moonlight.enable = lib.mkEnableOption "Moonlight game streaming client";

    config = lib.mkIf config.programs.moonlight.enable {
      environment.systemPackages = [pkgs.moonlight-qt];
    };
  };
}
