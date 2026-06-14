{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.maestro-studio = let
      pname = "maestro-studio";
      version = "0.9.3";
      src = pkgs.fetchurl {
        url = "https://github.com/mobile-dev-inc/maestro-studio/releases/download/v${version}/linux-Maestro-Studio-x86_64.AppImage";
        hash = "sha256-5UdVc0DQuy8FmmVfqr965+pyu4gRUKICoWuUFummE0k=";
      };
      appimageContents = pkgs.appimageTools.extract {inherit pname version src;};
      meta = {
        description = "Visual desktop app for Maestro mobile test automation";
        homepage = "https://maestro.dev";
        license = lib.licenses.unfree;
        platforms = ["x86_64-linux"];
      };
    in
      if system != "x86_64-linux"
      then throw "maestro-studio: ${system} is unsupported."
      else
        pkgs.appimageTools.wrapType2 {
          inherit pname version src meta;
          extraInstallCommands = ''
            desktop_file="${appimageContents}/maestro-studio.desktop"
            if [ -f "$desktop_file" ]; then
              install -m 444 -D "$desktop_file" $out/share/applications/maestro-studio.desktop
              sed -i 's|^Exec=.*|Exec=maestro-studio --no-sandbox|' $out/share/applications/maestro-studio.desktop
            fi
            for size in 16 32 48 64 128 256 512; do
              icon="${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/maestro-studio.png"
              if [ -f "$icon" ]; then
                install -m 444 -D "$icon" $out/share/icons/hicolor/''${size}x''${size}/apps/maestro-studio.png
              fi
            done
            mv $out/bin/${pname} $out/bin/.${pname}-unwrapped
            cat > $out/bin/${pname} <<EOF
            #!/bin/sh
            exec $out/bin/.${pname}-unwrapped --no-sandbox "\$@"
            EOF
            chmod +x $out/bin/${pname}
          '';
        };
  };

  flake.nixosModules.maestro-studio = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.maestro-studio = {
      enable = lib.mkEnableOption "Maestro Studio";
    };
    config = lib.mkIf config.programs.maestro-studio.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.maestro-studio
      ];
    };
  };
}
