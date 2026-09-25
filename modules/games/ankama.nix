{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.ankama = let
      pname = "ankama-launcher";
      version = "3.14.48";
      src = pkgs.fetchurl {
        url = "https://launcher.cdn.ankama.com/installers/production/Ankama%20Launcher-Setup-x86_64.AppImage";
        hash = "sha256-6q0kAFXtrnud8rvxN6o6mIiwklzjZYAopf1MlS3ODbU=";
      };
      appimageContents = pkgs.appimageTools.extract {inherit pname version src;};
      meta = {
        description = "Ankama Launcher";
        homepage = "https://www.ankama.com/en/launcher";
        license = lib.licenses.unfree;
        platforms = ["x86_64-linux"];
      };
    in
      if system != "x86_64-linux"
      then throw "ankama-launcher: ${system} is unsupported."
      else
        pkgs.appimageTools.wrapType2 {
          inherit pname version src meta;
          extraPkgs = p: [p.wine];
          extraInstallCommands = ''
            desktop_file="${appimageContents}/zaap.desktop"
            install -m 444 -D "$desktop_file" $out/share/applications/ankama-launcher.desktop
            sed -i 's|^Exec=.*|Exec=ankama-launcher|' $out/share/applications/ankama-launcher.desktop
            install -m 444 -D ${appimageContents}/zaap.png $out/share/icons/hicolor/256x256/apps/zaap.png
          '';
        };
  };

  flake.nixosModules.ankama = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.ankama = {
      enable = lib.mkEnableOption "Ankama Launcher";
    };

    config = lib.mkIf config.programs.ankama.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.ankama
      ];
    };
  };
}
