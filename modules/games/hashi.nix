{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.hashi = let
      pname = "hashi";
      version = "0.1.4";
      src = pkgs.fetchurl {
        url = "https://github.com/aleju03/hashi/releases/download/v${version}/Hashi_${version}_amd64.AppImage";
        hash = "sha256-rVYHu6+7JHpk6/pYNolDTD2SiTJIJrKJS0YGJjTtwwQ=";
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
        description = "Connects osu!mania to Mania Tracker: score submission, per-mod leaderboards and live status";
        homepage = "https://github.com/aleju03/hashi";
        downloadPage = "https://mania-tracker.com/hashi";
        license = lib.licenses.mit;
        sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
        mainProgram = "hashi";
        platforms = ["x86_64-linux"];
      };
    in
      if system != "x86_64-linux"
      then throw "hashi: ${system} is unsupported."
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
            install -m 444 -D ${appimageContents}/Hashi.desktop $out/share/applications/hashi.desktop
            sed -i 's|^Exec=.*|Exec=hashi|' $out/share/applications/hashi.desktop
            for size in 32 128; do
              install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/mania-bridge.png \
                $out/share/icons/hicolor/''${size}x''${size}/apps/mania-bridge.png
            done
            install -m 444 -D ${appimageContents}/Hashi.png $out/share/icons/hicolor/256x256/apps/mania-bridge.png
          '';
        };
  };

  flake.nixosModules.hashi = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.hashi = {
      enable = lib.mkEnableOption "Hashi (osu!mania → Mania Tracker bridge)";
    };

    config = lib.mkIf config.programs.hashi.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.hashi
      ];
    };
  };
}
