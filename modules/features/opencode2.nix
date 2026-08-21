{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.opencode2 = let
      version = "1.18.20";

      sources = {
        x86_64-linux = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
        aarch64-linux = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-linux-arm64/-/cli-linux-arm64-${version}.tgz";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
        x86_64-darwin = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-darwin-x64/-/cli-darwin-x64-${version}.tgz";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
        aarch64-darwin = {
          url = "https://registry.npmjs.org/@opencode-ai/cli-darwin-arm64/-/cli-darwin-arm64-${version}.tgz";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };

      src = pkgs.fetchurl {
        inherit (sources.${system}) url hash;
      };
    in
      pkgs.stdenv.mkDerivation {
        pname = "opencode2";
        inherit version src;

        nativeBuildInputs = lib.optionals pkgs.stdenv.isLinux [
          pkgs.autoPatchelfHook
        ];

        # npm tarballs always extract to a `package/` subdirectory
        sourceRoot = "package";

        unpackPhase = ''
          runHook preUnpack
          tar -xzf $src
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp bin/opencode2 $out/bin/opencode2
          runHook postInstall
        '';

        meta = {
          description = "Open source AI coding agent built for the terminal (v2 beta)";
          homepage = "https://opencode.ai";
          license = lib.licenses.mit;
          platforms = builtins.attrNames sources;
          mainProgram = "opencode2";
        };
      };
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
