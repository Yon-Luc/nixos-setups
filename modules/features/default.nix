{self, ...}: {
  flake.nixosModules = {
    packagesDefault = {pkgs, ...}: {
      imports = [
        self.nixosModules.ghostty
        self.nixosModules.zen
        self.nixosModules.bun
      ];
      programs.bun.enable = true;

      environment.systemPackages = with pkgs; [
        # cli tools
        easyeffects
        git
        gh
        vim
        tree
        jq
        curl
        kdePackages.dolphin
        btop
        mpv
        nmap
        tmux
        yt-dlp
        yazi
        # apps
        alacritty
        fastfetch
        pavucontrol
        vlc
        mpc-qt
        (signal-desktop.overrideAttrs (old: {
          installPhase =
            (old.installPhase or "")
            + ''
              wrapProgram $out/bin/signal-desktop \
                --add-flags "--password-store=kwallet6"
            '';
        }))
        vesktop
        (chromium.override {
          commandLineArgs = "--password-store=kwallet6";
        })
        pear-desktop
        usbimager
      ];
    };

    gamesDefault = {pkgs, ...}: {
      hardware.wooting.enable = true;
      hardware.openrazer.enable = true;

      imports = [
        self.nixosModules.osu
        self.nixosModules.tosu
        self.nixosModules.ankama
        self.nixosModules.sunshine
        self.nixosModules.osumania-map-analyser
        self.nixosModules.maniaMapAnalyserApp
        self.nixosModules.interlude
      ];

      environment.systemPackages = with pkgs; [
        bottles
        obs-studio
        wooting-udev-rules
        wootility
        openrazer-daemon
        polychromatic
        parsec-bin
      ];

      hardware.opentabletdriver.enable = true;

      hardware.uinput.enable = true;
      boot.kernelModules = ["uinput"];

      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
        osu.enable = true;
        tosu.enable = true;
        ankama.enable = true;
        tosuPlugins.maniaMapAnalyser = {
          enable = true;
          user = "yonluc";
        };
        maniaMapAnalyserApp.enable = true;
        interlude.enable = true;
      };
      programs.sunshine.enable = true;
    };

    developmentDefault = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        # gui
        podman-desktop
        beekeeper-studio
        cursor-cli
        vscode-fhs
        cloudflared
        # cli / devtools
        xdotool
        wmctrl
        opencode
        dig
        kubectl
        nodejs_24
        maestro
        pnpm
        nmap
        vim
        ethtool
        podman-compose
        runc
        conmon
        openssl
      ];
      programs.direnv.enable = true;

      nixpkgs.config.permittedInsecurePackages = [
        "beekeeper-studio-5.6.5"
      ];

      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };
    };
  };
}
