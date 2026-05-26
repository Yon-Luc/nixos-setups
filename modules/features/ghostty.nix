{...}: {
  flake.nixosModules.ghostty = {
    pkgs,
    lib,
    config,
    ...
  }: let
    ghosttySettings = {
      theme = "catppuccin-mocha";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;

      background-opacity = 0.92;
      cursor-style = "block";

      window-padding-x = 10;
      window-padding-y = 10;

      shell-integration = "fish";
    };

    toGhosttyConfig = attrs:
      lib.concatStringsSep "\n"
      (lib.mapAttrsToList (k: v: "${k} = ${toString v}") attrs);

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
