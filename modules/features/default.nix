{...}: {
  flake.nixosModules.packagesDefault = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      git
      gh
      vim
      kitty
      btop
      nmap
      bun
      alacritty
      fastfetch
      pear-desktop
      vesktop
    ];
  };
}
