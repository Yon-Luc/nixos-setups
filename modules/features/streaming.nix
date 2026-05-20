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
        capSysAdmin = true; # required for virtual display
        openFirewall = true;
      };

      security.wrappers.sunshine = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+p";
        source = "${pkgs.sunshine}/bin/sunshine";
      };
    };
    programs.sunshine.enable = true;
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
