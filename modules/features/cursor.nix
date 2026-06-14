{...}: {
  flake.nixosModules.cursor = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cursorSettings = {
      "files.watcherExclude" = {
        "**/node_modules/**" = true;
        "**/.git/**" = true;
        "**/dist/**" = true;
      };
      "window.commandCenter" = true;
      "workbench.sideBar.location" = "right";
      "todo-tree.highlights.customHighlight" = {
        "TODO" = {
          "icon" = "check";
          "type" = "text";
          "foreground" = "#ffffff";
          "background" = "#2563EB";
        };
        "FIXME" = {
          "icon" = "flame";
          "type" = "text";
          "foreground" = "#ffffff";
          "background" = "#DC2626";
        };
      };
      "workbench.editor.showTabs" = "single";
      "workbench.colorTheme" = "Bearded Theme Arc EolStorm";
      "git.confirmSync" = false;
      "breadcrumbs.enabled" = false;
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.formatOnSave" = true;
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[javascriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[astro]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "prettier.documentSelectors" = [
        "**/*.astro"
        "**/*.ts"
        "**/*.tsx"
      ];
      "editor.quickSuggestions" = {
        "strings" = "on";
      };
      "typescript.updateImportsOnFileMove.enabled" = "always";
      "console-ninja.featureSet" = "Community";
      "nix.serverPath" = "nixd";
      "nix.formatterPath" = "alejandra";
      "nix.enableLanguageServer" = true;
      "nix.serverSettings" = {
        "nixd" = {
          "formatting" = {
            "command" = ["alejandra"];
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      code-cursor-fhs
      nixd
      alejandra
    ];

    extensions =
      (with pkgs.vscode-extensions; [
        adpyke.codesnap
        astro-build.astro-vscode
        bbenoist.nix
        biomejs.biome
        bradlc.vscode-tailwindcss
        esbenp.prettier-vscode
        gruntfuggly.todo-tree
        jnoortheen.nix-ide
        johnpapa.vscode-peacock
        unifiedjs.vscode-mdx
        usernamehw.errorlens
        yoavbls.pretty-ts-errors
      ])
      ++ (map pkgs.vscode-utils.buildVscodeMarketplaceExtension [
        {
          mktplcRef = {
            name = "beardedtheme";
            publisher = "beardedbear";
            version = "9.3.0";
            sha256 = "sha256-MwcxAFwP1usfs5K4e1nBxGetEHbAH1PzE1WT2kNW7Vs=";
          };
        }
        {
          mktplcRef = {
            name = "es7-react-js-snippets";
            publisher = "dsznajder";
            version = "4.4.3";
            sha256 = "sha256-QF950JhvVIathAygva3wwUOzBLjBm7HE3Sgcp7f20Pc=";
          };
        }
        {
          mktplcRef = {
            name = "console-ninja";
            publisher = "wallabyjs";
            version = "1.0.527";
            sha256 = "sha256-zQ/56HbcLxVKa2X37mnvdVEhVGYm9RQ01J0m34sA9sU=";
          };
        }
      ]);

    extensionsEnv = pkgs.buildEnv {
      name = "cursor-extensions";
      paths = extensions;
    };

    settingsJSON =
      pkgs.writeText "cursor-settings.json"
      (builtins.toJSON cursorSettings);

    realUsers = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
  in {
    environment.systemPackages = with pkgs; [
      code-cursor-fhs
      nixd
      alejandra
    ];

    system.activationScripts.cursorSettings = {
      text = lib.concatMapStrings (
        user: let
          settingsDir = "${user.home}/.config/Cursor/User";
        in ''
          mkdir -p ${settingsDir}
          cp --no-preserve=mode ${settingsJSON} ${settingsDir}/settings.json
          chown ${user.name} ${settingsDir}/settings.json
        ''
      ) (lib.attrValues realUsers);
      deps = [];
    };

    system.activationScripts.cursorExtensions = {
      text = lib.concatMapStrings (
        user: ''
          mkdir -p ${user.home}/.cursor/extensions
          for ext in ${extensionsEnv}/share/vscode/extensions/*; do
            extname=$(basename $ext)
            if [ ! -e "${user.home}/.cursor/extensions/$extname" ]; then
              ln -sf $ext ${user.home}/.cursor/extensions/$extname
            fi
          done
          chown -R ${user.name} ${user.home}/.cursor/extensions
        ''
      ) (lib.attrValues realUsers);
      deps = [];
    };
  };
}
