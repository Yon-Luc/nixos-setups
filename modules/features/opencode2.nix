{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.opencode2 = let
      version = "0.0.0-next-17444";

      sources = {
        x86_64-linux = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
          hash = "sha256-54iGtij74Sck19YItCjrww8PHPhBPrMbHt2d4FZzms8=";
        };

        aarch64-linux = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-linux-arm64/-/cli-linux-arm64-${version}.tgz";
          hash = "sha256-u9m94vtXFmSu5bKcZ3HdbRD9Xlmo7bXtJ3N/8vVSviU=";
        };

        x86_64-darwin = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-darwin-x64/-/cli-darwin-x64-${version}.tgz";
          hash = "sha256-BdzXsFUYenrC3GcQkKn5DqrY7pM9ve7WaEPaImp8pOk=";
        };

        aarch64-darwin = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-darwin-arm64/-/cli-darwin-arm64-${version}.tgz";
          hash = "sha256-kJEZ6dwUayg4qfbGPB1kBX03hqLMpjh/saHcodMRYzs=";
        };
      };

      src = pkgs.fetchurl {
        inherit (sources.${system}) url hash;
      };

      opencode2-unwrapped = pkgs.stdenv.mkDerivation {
        pname = "opencode2-unwrapped";
        inherit version src;

        dontPatchELF = true;
        dontAutoPatch = true;
        dontFixup = true;

        sourceRoot = "package";

        unpackPhase = ''
          runHook preUnpack
          tar -xzf $src
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall

          # Preserve the entire npm package layout.
          # OpenCode may need files/resources alongside bin/opencode2.
          mkdir -p $out
          cp -r . $out/

          chmod +x $out/bin/opencode2

          runHook postInstall
        '';
      };

      fhs = pkgs.buildFHSEnv {
        name = "opencode2";

        targetPkgs = _: [
          opencode2-unwrapped
        ];

        runScript = pkgs.writeShellScript "opencode2-wrapper" ''
          export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}/opencode2"
          export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/opencode2"
          export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}/opencode2"
          export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}/opencode2"

          exec ${opencode2-unwrapped}/bin/opencode2 "$@"
        '';

        meta = {
          description = "Open source AI coding agent built for the terminal (v2)";
          homepage = "https://opencode.ai";
          license = lib.licenses.mit;
          platforms = builtins.attrNames sources;
          mainProgram = "opencode2";
        };
      };
    in
      fhs;
  };

  flake.nixosModules.opencode2 = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.opencode2 = {
      enable = lib.mkEnableOption "OpenCode v2 AI coding agent";
    };

    config = lib.mkIf config.programs.opencode2.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.opencode2
      ];
    };
  };
}
