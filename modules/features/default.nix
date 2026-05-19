{self, ...}: {
  flake.nixosModules.packagesDefault = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      git
      gh
      vim
      tree
      jq
      curl
      btop
      nmap
      bun
      alacritty
      fastfetch
      pavucontrol
      pear-desktop
      vlc
      signal-desktop
      vesktop
      yt-dlp
      tmux
      chromium
    ];
  };

  flake.nixosModules.gamesDefault = {pkgs, ...}: {
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

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    programs.osu.enable = true;
    programs.ankama.enable = true;
  };

  flake.nixosModules.developmentDefault = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      xdotool
      wmctrl
      opencode
      podman-compose
      podman-desktop
      kubectl
      nodejs_24
      nmap
      vim
      ethtool
      beekeeper-studio
      pnpm
    ];
    nixpkgs.config.permittedInsecurePackages = ["beekeeper-studio-5.6.5"];
  };
}
