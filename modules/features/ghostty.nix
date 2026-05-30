{...}: {
  flake.nixosModules.ghostty = {
    pkgs,
    lib,
    config,
    ...
  }: let
    ghosttySettings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;

      background-opacity = 0.92;
      cursor-style = "block";

      window-padding-x = 10;
      window-padding-y = 10;

      shell-integration = "fish";
      backspace-binding = "delete";

      # === mapped from Rose Pine Moon (Noctalia) ===
      foreground = "#e0def4"; # mOnSurface
      background = "#232136"; # mSurface

      cursor-color = "#ea9a97"; # mPrimary
      selection-background = "#393552"; # mSurfaceVariant

      palette = [
        "#232136" # black (surface)
        "#eb6f92" # red (error)
        "#9ccfd8" # green (secondary)
        "#f6c177" # yellow (not provided → Rose Pine amber substitute)
        "#3e8fb0" # blue (tertiary)
        "#c4a7e7" # magenta (derived Rose Pine purple)
        "#9ccfd8" # cyan (secondary reused)
        "#e0def4" # white (onSurface)

        "#44415a" # bright black (outline)
        "#eb6f92" # bright red
        "#9ccfd8" # bright green
        "#f6c177" # bright yellow
        "#3e8fb0" # bright blue
        "#c4a7e7" # bright magenta
        "#9ccfd8" # bright cyan
        "#e0def4" # bright white
      ];
    };

    toGhosttyConfig = attrs:
      lib.concatStringsSep "\n"
      (lib.concatMap
        (k:
          if builtins.isList attrs.${k}
          then lib.imap0 (i: color: "${k} = ${toString i}=${color}") attrs.${k}
          else ["${k} = ${toString attrs.${k}}"])
        (builtins.attrNames attrs));

    settingsFile =
      pkgs.writeText "ghostty-config" (toGhosttyConfig ghosttySettings);

    realUsers =
      lib.filterAttrs (_: u: u.isNormalUser) config.users.users;
  in {
    environment.systemPackages = with pkgs; [
      ghostty
    ];

    system.activationScripts.ghosttyGhosttyConfig.text = lib.concatMapStrings (user: ''
      mkdir -p ${user.home}/.config/ghostty

      ln -sf ${settingsFile} ${user.home}/.config/ghostty/config

      chown -h ${user.name}:${user.group or "users"} \
        ${user.home}/.config/ghostty/config
    '') (lib.attrValues realUsers);
  };
}
