{self, ...}: {
  flake.nixosModules.sunshine = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.sunshine.enable = lib.mkEnableOption "Sunshine game streaming host";

    config = lib.mkIf config.programs.sunshine.enable {
      environment.systemPackages = [pkgs.sunshine];

      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    };
  };

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
