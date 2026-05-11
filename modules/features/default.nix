{ self, inputs, ... }: {
  flake.nixosModules.packagesDefault = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      gh
      vim
      btop
      nmap
      code-cursor-fhs
      bun
      alacritty
      fastfetch
      pear-desktop
      vesktop
    ];
  };
}