{self, ...}: {
  flake.nixosModules = {
    packagesDefault = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        # cli tools
        git
        gh
        vim
        tree
        jq
        curl
        btop
        nmap
        tmux
        yt-dlp

        # apps
        alacritty
        fastfetch
        pavucontrol
        vlc
        signal-desktop
        vesktop
        chromium
        pear-desktop
        usbimager
      ];
    };

    gamesDefault = {pkgs, ...}: {
      imports = [
        self.nixosModules.osu
        self.nixosModules.ankama
      ];

      environment.systemPackages = with pkgs; [
        obs-studio
        wooting-udev-rules
        wootility
      ];

      hardware.wooting.enable = true;

      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
        osu.enable = true;
        ankama.enable = true;
      };
    };

    developmentDefault = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        # gui
        podman-desktop
        beekeeper-studio

        # cli / devtools
        xdotool
        wmctrl
        opencode
        kubectl
        nodejs_24
        pnpm
        nmap
        vim
        ethtool
        podman-compose
        runc
        conmon
      ];

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
