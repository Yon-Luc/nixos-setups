{...}: {
  flake.nixosModules.nixBuilder = {...}: {
    nix.settings.trusted-users = ["root" "yonluc"];

    users.users.yonluc.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt8iwH+omLlGX+Nbujwy0EEvf2S4MrX5Ex0pF1h/AUA yonluc@yont2"
    ];
  };
}
