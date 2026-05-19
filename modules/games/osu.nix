{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.osu = let
      pname = "osu-lazer-bin";
      version = "2026.518.0";
      nativeWayland = false;
      src =
        {
          aarch64-darwin = pkgs.fetchzip {
            url = "https://github.com/ppy/osu/releases/download/${version}-lazer/osu.app.Apple.Silicon.zip";
            hash = "sha256-Asqz0jiiHTtLcBzvibNzlaRe0jAop5YU4gmooZf/8gw=";
            stripRoot = false;
          };
          x86_64-darwin = pkgs.fetchzip {
            url = "https://github.com/ppy/osu/releases/download/${version}-lazer/osu.app.Intel.zip";
            hash = "sha256-2ZAZ3CnYz/6VJxqpDNvx6jGcNV/9oo8Eb5/GkSidiv0=";
            stripRoot = false;
          };
          x86_64-linux = pkgs.fetchurl {
            url = "https://github.com/ppy/osu/releases/download/${version}-lazer/osu.AppImage";
            hash = "sha256-4LLNjrKEBS77LIbq+O6Xpxj6CvufGDApNqs61HN2JmA=";
          };
        }.${
          system
        } or (throw "osu-lazer-bin: ${system} is unsupported.");

      meta = {
        description = "Rhythm is just a *click* away";
        homepage = "https://osu.ppy.sh";
        license = with lib.licenses; [mit cc-by-nc-40 unfreeRedistributable];
        sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
        mainProgram = "osu!";
        platforms = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];
      };
    in
      if pkgs.stdenvNoCC.hostPlatform.isDarwin
      then
        pkgs.stdenvNoCC.mkDerivation {
          inherit pname version src meta;
          nativeBuildInputs = [pkgs.makeWrapper];
          installPhase = ''
            runHook preInstall
            OSU_WRAPPER="$out/Applications/osu!.app/Contents"
            OSU_CONTENTS="osu!.app/Contents"
            mkdir -p "$OSU_WRAPPER/MacOS"
            cp -r "$OSU_CONTENTS/Info.plist" "$OSU_CONTENTS/Resources" "$OSU_WRAPPER"
            cp -r "osu!.app" "$OSU_WRAPPER/Resources/osu-wrapped.app"
            makeWrapper "$OSU_WRAPPER/Resources/osu-wrapped.app/Contents/MacOS/osu!" \
              "$OSU_WRAPPER/MacOS/osu!" \
              --set OSU_EXTERNAL_UPDATE_PROVIDER 1
            runHook postInstall
          '';
        }
      else
        pkgs.appimageTools.wrapType2 {
          inherit pname version src meta;
          extraPkgs = p: with p; [icu];
          extraInstallCommands = let
            contents = pkgs.appimageTools.extract {inherit pname version src;};
          in ''
            . ${pkgs.makeWrapper}/nix-support/setup-hook
            mv -v $out/bin/${pname} $out/bin/osu!
            wrapProgram $out/bin/osu! \
              ${lib.optionalString nativeWayland "--set SDL_VIDEODRIVER wayland"} \
              --set OSU_EXTERNAL_UPDATE_PROVIDER 1
            install -m 444 -D ${contents}/osu!.desktop -t $out/share/applications
            for i in 16 32 48 64 96 128 256 512 1024; do
              install -D ${contents}/osu.png $out/share/icons/hicolor/''${i}x$i/apps/osu.png
            done
          '';
        };
  };

  flake.nixosModules.osu = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.osu = {
      enable = lib.mkEnableOption "osu!lazer";
      nativeWayland = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable native Wayland support via SDL_VIDEODRIVER";
      };
    };

    config = lib.mkIf config.programs.osu.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.osu
      ];
    };
  };
}
