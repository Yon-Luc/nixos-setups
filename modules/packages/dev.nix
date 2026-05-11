{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nixosSettings.packageGroups.dev = with pkgs; [
    git
    nmap
    alacritty
    gh
    bun
  ];
}