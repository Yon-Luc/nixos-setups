{ self, inputs, ... }: {

  flake.nixosModules.macConfiguration =  { config, pkgs, ... }:

  {
  imports =
    [ # Include the results of the hardware scan.
      self.nixosModules.macHardware
      self.nixosModules.niri
      self.nixosModules.packagesDefault
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-mac"; # Define your hostname.
 
  networking.networkmanager.enable = true;


  hardware.enableRedistributableFirmware = true;

  boot.kernelModules = [ "wl" ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  boot.blacklistedKernelModules = [
    "bcma"
    "b43"
    "brcmsmac"
    "ssb"
  ];


  time.timeZone = "Europe/Lisbon";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = false;

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  users.users.yonmac = {
    isNormalUser = true;
    description = "yonmac";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    
  ];

   nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.18.26"
    "broadcom-sta-6.30.223.271-59-6.18.20"
  ];




  system.stateVersion = "25.11"; 

    };
}
