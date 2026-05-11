{...}: {
  flake.homeModules.cursor = {pkgs, ...}: {
    programs.vscode = {
      enable = true;

      package = pkgs.code-cursor-fhs;

      profiles.default = {
        userSettings = {
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

        extensions = with pkgs.vscode-extensions; [
          adpyke.codesnap
          anysphere.remote-ssh
          astro-build.astro-vscode
          bbenoist.nix
          beardedbear.beardedtheme
          biomejs.biome
          bradlc.vscode-tailwindcss
          dsznajder.es7-react-js-snippets
          esbenp.prettier-vscode
          gruntfuggly.todo-tree
          jnoortheen.nix-ide
          johnpapa.vscode-peacock
          openai.chatgpt
          oven.bun-vscode
          sst-dev.opencode
          unifiedjs.vscode-mdx
          usernamehw.errorlens
          wallabyjs.console-ninja
          yoavbls.pretty-ts-errors
        ];
      };
    };
  };
}
