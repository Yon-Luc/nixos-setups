{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.interlude = let
      pname = "interlude";
      version = "0.7.28.2";
      icon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/YAVSRG/YAVSRG/main/interlude/src/Resources/icon.png";
        hash = "sha256-YvQ6F2RHjbKGDm60XnKTbk8GhyXsdOO5WpgUS6LdS4w=";
      };
      desktopItem = pkgs.makeDesktopItem {
        name = "interlude";
        desktopName = "Interlude";
        comment = "Keyboard-based vertically scrolling rhythm game";
        exec = "interlude";
        icon = "interlude";
        categories = ["Game"];
      };
      src =
        {
          x86_64-linux = pkgs.fetchzip {
            url = "https://github.com/YAVSRG/YAVSRG/releases/download/interlude-v${version}/Interlude-linux-x64.zip";
            hash = "sha256-WBRw60gerWgxFZfLekliCkFtlDFD5aSXwiaLAuow5qA=";
            stripRoot = false;
          };
        }.${
          system
        } or (throw "interlude: ${system} is unsupported.");

      runtimeLibs = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        icu
        libGL
        alsa-lib
        libpulseaudio
        libx11
        libxcursor
        libxi
        libxrandr
        libxinerama
        libxext
        wayland
        libxkbcommon
      ];
    in
      pkgs.stdenv.mkDerivation {
        inherit pname version src;

        nativeBuildInputs = [pkgs.autoPatchelfHook pkgs.makeWrapper];
        buildInputs = runtimeLibs;

        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/interlude
          cp -r . $out/opt/interlude/
          chmod +x $out/opt/interlude/Interlude

          mkdir -p $out/bin
          cat > $out/bin/interlude <<EOF
          #!${pkgs.runtimeShell}
          set -e
          export LD_LIBRARY_PATH="${lib.makeLibraryPath runtimeLibs}\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"

          GAME_STORE="$out/opt/interlude"
          DATA="\''${XDG_DATA_HOME:-\$HOME/.local/share}/interlude"
          mkdir -p "\$DATA"

          # Interlude is portable: it stores data next to its executable, so copy
          # the (immutable) store binary into a writable location on upgrades.
          if [ "\$(cat "\$DATA/.store-path" 2>/dev/null)" != "\$GAME_STORE" ]; then
            install -m755 "\$GAME_STORE/Interlude" "\$DATA/Interlude"
            printf '%s' "\$GAME_STORE" > "\$DATA/.store-path"
          fi

          # The bundled native libs must sit beside the executable.
          for lib in libbass.so libbass_fx.so libe_sqlite3.so libglfw.so.3.3; do
            ln -sfn "\$GAME_STORE/\$lib" "\$DATA/\$lib"
          done

          cd "\$DATA"
          exec "\$DATA/Interlude" "\$@"
          EOF
          chmod +x $out/bin/interlude

          install -Dm444 ${icon} $out/share/icons/hicolor/256x256/apps/interlude.png
          mkdir -p $out/share
          cp -r ${desktopItem}/share/applications $out/share/applications

          runHook postInstall
        '';

        meta = {
          description = "The most based keyboard-based vertically scrolling rhythm game";
          homepage = "https://yavsrg.net";
          license = lib.licenses.gpl3Plus;
          sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
          mainProgram = "interlude";
          platforms = ["x86_64-linux"];
        };
      };
  };

  flake.nixosModules.interlude = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.interlude = {
      enable = lib.mkEnableOption "Interlude (keyboard rhythm game)";
    };

    config = lib.mkIf config.programs.interlude.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.interlude
      ];
    };
  };
}
