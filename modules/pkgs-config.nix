{inputs, ...}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        # noctalia-qs 0.0.12 fails to moc Hyprland/i3 IPC types on Qt 6.12.
        # Same change as quickshell 5d5d498 (Q_MOC_INCLUDE instead of opaque pointers).
        (final: prev: {
          noctalia-qs = prev.noctalia-qs.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              ./noctalia-qs-qt-6.12.patch
            ];
          });
          # Qt 6.12's QtQuick.Color singleton shadows noctalia's Color.qml,
          # which leaves the bar and panels black.
          noctalia-shell = (prev.noctalia-shell.override {
            noctalia-qs = final.noctalia-qs;
          }).overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              mv "$out/share/noctalia-shell/Commons/Color.qml" \
                "$out/share/noctalia-shell/Commons/ShellColor.qml"
              find "$out/share/noctalia-shell" -name '*.qml' -print0 \
                | xargs -0 sed -i -E 's/(^|[^A-Za-z0-9_])Color\./\1ShellColor./g'
            '';
          });
        })
      ];
    };
  };
}
