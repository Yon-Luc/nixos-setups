{...}: {
  flake.nixosModules.nixRemoteBuilders = {...}: {
    nix.distributedBuilds = true;

    nix.buildMachines = [
      {
        hostName = "main";
        systems = ["x86_64-linux"];
        maxJobs = 8;
        speedFactor = 2;
        sshUser = "yonluc";
        sshKey = "/etc/nix/ssh-keys/nix-builder-main";
        supportedFeatures = ["big-parallel" "kvm"];
      }
    ];

    nix.settings.builders-use-substitutes = true;

    programs.ssh.extraConfig = ''
      Host main
        IdentityFile /etc/nix/ssh-keys/nix-builder-main
        IdentitiesOnly yes
        StrictHostKeyChecking accept-new
    '';
  };
}
