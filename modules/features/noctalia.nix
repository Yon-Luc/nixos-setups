{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    baseSettings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
    baseState = (builtins.fromJSON (builtins.readFile ./noctalia.json)).state;
    username = "yonluc";
    home = "/home/${username}";
    wallpaperDir = "${home}/nixos-setups/modules/wallpaper";
  in {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings =
        baseSettings
        // {
          general =
            baseSettings.general
            // {
              avatarImage = "${wallpaperDir}/483972423_1060871462740177_661005155653802445_n.jpg";
            };
          wallpaper =
            baseSettings.wallpaper
            // {
              directory = wallpaperDir;
            };
        };
      state =
        baseState
        // {
          wallpapers = {
            "eDP-1" = "${wallpaperDir}/shinobu.jpg";
            "DP-5" = "${wallpaperDir}/shinobu.jpg";
            "DP-4" = "${wallpaperDir}/monogatari-series-anime-girls-oshino-shinobu-wallpaper-cac5c4f0c2f8646d1f085d86c9563256.jpg";
          };
        };
    };
  };
}
