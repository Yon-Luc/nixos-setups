{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];
        prefer-no-csd = true;
        outputs = {
          "DP-4" = {
            mode = "1920x1080@144.001";
          };
          "DP-5" = {
            transform = "270";
          };
        };
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        input.keyboard.xkb.layout = "us,ua";
        layout.gaps = 5;

        window-rules = [
          {
            matches = [{app-id = "^mania-map-analyser-app$";}];
            open-floating = true;
            default-column-width.fixed = 520;
            default-window-height.fixed = 610;
            min-width = 520;
            max-width = 520;
            min-height = 610;
            max-height = 610;
          }
        ];

        binds =
          {
            "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
            "Mod+Q".close-window = _: {};
            "Mod+Left".focus-column-left = {};
            "Mod+Down".focus-window-down = {};
            "Mod+Up".focus-window-up = {};
            "Mod+Right".focus-column-right = {};
            "Mod+H".focus-column-left = {};
            "Mod+J".focus-window-down = {};
            "Mod+K".focus-window-up = {};
            "Mod+L".focus-column-right = {};
            "Mod+Escape".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
            "Mod+Ctrl+Shift+Left".move-window-to-monitor-left = {};
            "Mod+Ctrl+Shift+Right".move-window-to-monitor-right = {};
            "Mod+Ctrl+Left".focus-monitor-left = {};
            "Mod+Ctrl+Right".focus-monitor-right = {};
            "Ctrl+Backslash".screenshot = {};
            "Mod+Ctrl+Backslash".screenshot-screen = {};
            "Ctrl+Shift+Backslash".screenshot-window = {};
            "Mod+F".fullscreen-window = {};
            "Mod+M".maximize-window-to-edges = {};
            "Mod+Shift+Left".move-column-left = {};
            "Mod+Shift+Down".move-window-down = {};
            "Mod+Shift+Up".move-window-up = {};
            "Mod+V".toggle-window-floating = {};
            "Mod+Shift+Right".move-column-right = {};
            "Mod+Shift+H".move-column-left = {};
            "Mod+Shift+J".move-window-down = {};
            "Mod+Shift+K".move-window-up = {};
            "Mod+Shift+L".move-column-right = {};
            "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
            "Mod+B".spawn-sh = lib.getExe self'.packages.zen-browser;
            "Mod+C".spawn-sh = lib.getExe pkgs.code-cursor-fhs;
          }
          // lib.mergeAttrsList (map (n: {
            "Ctrl+Shift+${toString n}".focus-workspace = n;
            "Ctrl+Shift+Alt+${toString n}".move-column-to-workspace = n;
          }) (lib.range 1 9));
      };
    };
  };
}
