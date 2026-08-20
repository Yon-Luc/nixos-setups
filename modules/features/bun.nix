{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.bun = let
      version = "1.4.0";

      sources = {
        x86_64-linux = {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
          hash = "sha256-Poy0vf7yJ/hzk33QiQj5gnshI5Q7dfbaMD7xgwiyDKw="; # replace with real hash
        };
        aarch64-linux = {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
        x86_64-darwin = {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-x64.zip";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
        aarch64-darwin = {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };

      src = pkgs.fetchzip {
        inherit (sources.${system}) url hash;
      };
    in
      pkgs.stdenv.mkDerivation {
        pname = "bun";
        inherit version src;

        nativeBuildInputs = [pkgs.autoPatchelfHook];

        installPhase = ''
          mkdir -p $out/bin
          cp bun $out/bin/bun
          ln -s $out/bin/bun $out/bin/bunx
        '';

        meta = {
          description = "Incredibly fast JavaScript runtime, bundler, transpiler and package manager";
          homepage = "https://bun.sh";
          license = lib.licenses.mit;
          platforms = builtins.attrNames sources;
          mainProgram = "bun";
        };
      };
  };
  flake.nixosModules.bun = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.bun = {
      enable = lib.mkEnableOption "Bun JavaScript runtime";
    };

    config = lib.mkIf config.programs.bun.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.bun
      ];
    };
  };
}
