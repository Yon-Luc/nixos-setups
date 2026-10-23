{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.backbeat = let
      pname = "backbeat";
      version = "1.0.0";
      src = pkgs.fetchurl {
        url = "https://github.com/zkldi/backbeat/releases/download/v${version}/Backbeat_${version}_amd64.AppImage";
        hash = "sha256-7ufRDLhkL+9gZImbFfBWJayz8Wrgg1NGn5FCaKLw2qs=";
      };
      appimageContents = pkgs.appimageTools.extract {inherit pname version src;};

      # AppImage/FHS leaves LD_LIBRARY_PATH / GIO modules set, so xdg-open either
      # fails or tries to launch the browser inside the sandbox. Clear that and
      # hand off to the host portal-aware xdg-open.
      xdgOpenClean = pkgs.writeShellScriptBin "xdg-open" ''
        unset LD_LIBRARY_PATH LD_PRELOAD GIO_MODULE_DIR GTK_PATH QT_PLUGIN_PATH
        unset PERLLIB PYTHONPATH GI_TYPELIB_PATH
        exec ${lib.getExe' pkgs.xdg-utils "xdg-open"} "$@"
      '';

      meta = {
        description = "Desktop app for managing a Backbeat rhythm-game content store";
        homepage = "https://backbeat.ac";
        downloadPage = "https://backbeat.ac/get-started/";
        changelog = "https://github.com/zkldi/backbeat/releases/tag/v${version}";
        license = lib.licenses.gpl3Only;
        sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
        mainProgram = "backbeat";
        platforms = ["x86_64-linux"];
      };
    in
      if system != "x86_64-linux"
      then throw "backbeat: ${system} is unsupported."
      else
        pkgs.appimageTools.wrapType2 {
          inherit pname version src meta;
          extraPkgs = pkgs: [xdgOpenClean];
          # FHS profile runs after the default PATH=… line, so this ends up first.
          profile = ''
            unset GIO_MODULE_DIR
            export PATH=${xdgOpenClean}/bin:$PATH
          '';
          extraInstallCommands = ''
            install -m 444 -D ${appimageContents}/usr/share/applications/Backbeat.desktop \
              $out/share/applications/backbeat.desktop
            sed -i \
              -e 's|^Exec=.*|Exec=backbeat %u|' \
              -e 's|^Categories=.*|Categories=AudioVideo;Game;|' \
              $out/share/applications/backbeat.desktop
            for size in 32 64 128 512; do
              install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/Backbeat.png \
                $out/share/icons/hicolor/''${size}x''${size}/apps/Backbeat.png
            done
          '';
        };
  };

  flake.nixosModules.backbeat = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.backbeat = {
      enable = lib.mkEnableOption "Backbeat (rhythm game content manager)";
    };

    config = lib.mkIf config.programs.backbeat.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.backbeat
      ];

      # So "Download with Backbeat" links (backbeat://) open the app.
      xdg.mime.defaultApplications."x-scheme-handler/backbeat" = "backbeat.desktop";
    };
  };
}
