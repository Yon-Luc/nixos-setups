{inputs, self, ...}: {
  flake.nixosModules.zen = {
    pkgs,
    lib,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    zenPkg = inputs.zen-browser.packages.${system}.twilight;
    realUsers = lib.filterAttrs (_: u: u.isNormalUser) config.users.users;

    mimeAppsFile = pkgs.writeText "zen-mimeapps.list" ''
      [Default Applications]
      x-scheme-handler/http=zen-twilight.desktop
      x-scheme-handler/https=zen-twilight.desktop
      x-scheme-handler/about=zen-twilight.desktop
      text/html=zen-twilight.desktop
    '';
  in {
    environment.sessionVariables.BROWSER = "zen-twilight";

    environment.systemPackages = [zenPkg];

    system.activationScripts.zenDefaultBrowser = {
      text = lib.concatMapStrings (user: ''
        mkdir -p ${user.home}/.config
        cp --no-preserve=mode ${mimeAppsFile} ${user.home}/.config/mimeapps.list
        chown ${user.name} ${user.home}/.config/mimeapps.list
      '') (lib.attrValues realUsers);
      deps = [];
    };
  };

  perSystem = {system, ...}: {
    packages.zen-browser = inputs.zen-browser.packages.${system}.twilight;
  };
}
