{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.osu = let
      pname = "osu-lazer-bin";
      version = "2026.624.0";
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
            hash = "sha256-EKmCq656djPGK5I1JqSDcTKtpbQZbO8WGWcPv+PT0q4=";
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
    packages.tosu = let
      pname = "tosu";
      version = "4.24.0";
      src = pkgs.fetchzip {
        url = "https://github.com/tosuapp/tosu/releases/download/v${version}/tosu-linux-v${version}.zip";
        hash = "sha256-EKTAhSjyYQCIL850G2Di5Lywwb8RGe3J3fOA6Q022KQ="; # replace with the hash `nix build` reports
        stripRoot = false;
      };
    in
      pkgs.stdenv.mkDerivation {
        inherit pname version src;
        dontConfigure = true;
        dontBuild = true;
        dontPatchELF = true; # critical: stdenv's default fixup phase would otherwise
        dontStrip = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/tosu $out/bin
          cp -r . $out/share/tosu/
          chmod +x $out/share/tosu/tosu
          ln -s $out/share/tosu/tosu $out/bin/tosu
          runHook postInstall
        '';
        meta = {
          description = "osu! (stable & lazer) memory reader and PP counter provider";
          homepage = "https://github.com/tosuapp/tosu";
          license = lib.licenses.lgpl3Only;
          sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
          mainProgram = "tosu";
          platforms = ["x86_64-linux"];
        };
      };
    packages.osumania-map-analyser = let
      pname = "osumania-map-analyser";
      version = "1.3.2";
      src = pkgs.fetchurl {
        url = "https://github.com/LeoBlackMT/osumania_map_analyser/releases/download/v${version}/ManiaMapAnalyser.by.Leo_Black.7z";
        hash = "sha256-C9YhuXEJIlr345GB2ca0HFq/D3dTaWuIlHOXJo8F/AI=";
      };
    in
      pkgs.stdenvNoCC.mkDerivation {
        inherit pname version src;
        nativeBuildInputs = [pkgs.p7zip];
        dontConfigure = true;
        dontBuild = true;
        unpackPhase = ''
          mkdir extracted
          7z x $src -oextracted
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          # if the archive has a single top-level directory, flatten it;
          # otherwise copy everything as-is. tosu wants the plugin folder
          # itself directly under static/, not double-nested.
          entries=(extracted/*)
          if [ "''${#entries[@]}" -eq 1 ] && [ -d "''${entries[0]}" ]; then
            cp -r "''${entries[0]}"/. $out/
          else
            cp -r extracted/. $out/
          fi
          runHook postInstall
        '';
        meta = {
          description = "Real-time osu!mania difficulty/pattern-analysis overlay plugin for tosu";
          homepage = "https://github.com/LeoBlackMT/osumania_map_analyser";
          platforms = lib.platforms.all; # pure static assets, no arch dependency
        };
      };
  };

  flake.nixosModules.tosu = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.tosu = {
      enable = lib.mkEnableOption "tosu (osu! memory reader for pp counters/overlays)";
      withPtraceCapability = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Wrap tosu with a security wrapper granting CAP_SYS_PTRACE, so it can read osu!'s process memory without running as root.";
      };
    };
    config = lib.mkIf config.programs.tosu.enable {
      environment.systemPackages = [self.packages.${pkgs.stdenv.hostPlatform.system}.tosu];

      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [icu stdenv.cc.cc.lib];

      security.wrappers = lib.mkIf config.programs.tosu.withPtraceCapability {
        tosu = {
          owner = "root";
          group = "root";
          capabilities = "cap_sys_ptrace=eip";
          source = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.tosu;
        };
      };
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
  flake.nixosModules.osumania-map-analyser = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.tosuPlugins.maniaMapAnalyser = {
      enable = lib.mkEnableOption "the osu!mania Map Analyser plugin for tosu";
      user = lib.mkOption {
        type = lib.types.str;
        description = "The user account whose ~/.local/share/tosu/static/ the plugin should be linked into.";
        example = "yonluc";
      };
    };
    config = lib.mkIf config.programs.tosuPlugins.maniaMapAnalyser.enable (
      let
        cfg = config.programs.tosuPlugins.maniaMapAnalyser;
        pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.osumania-map-analyser;
        homeDir = "/home/${cfg.user}";
      in {
        systemd.tmpfiles.rules = [
          "d ${homeDir}/.local/share/tosu 0755 ${cfg.user} users - -"
          "d ${homeDir}/.local/share/tosu/static 0755 ${cfg.user} users - -"
          "L+ ${homeDir}/.local/share/tosu/static/ManiaMapAnalyser - - - - ${pkg}"
        ];
      }
    );
  };
}
