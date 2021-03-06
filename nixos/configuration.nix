# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];
  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Needs home manager channel
  # https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
  # #nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
  # #nix-channel --update

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "helios"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Enable video drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  
   users.users.david = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
  };

  home-manager.users.david = { pkgs, ... }: {
    home.packages = with pkgs; [
      gnomeExtensions.appindicator
      gnome.gnome-boxes
      gnome.gnome-tweaks 
      lolcat
    ];

    programs.firefox = {
      enable = true;
    };
 
    programs.git = {
      #program installed system wide
      enable = true;
      userName = "David Hirsch";
      userEmail = "dhirsch1138@gmail.com";
    };
    
    home.file = {
      #Auto run the fractart generation program on login
      #this puts the generated bmp in
      # ./fractalart/wallpaper.bmp
      # the dconf configuration will set that generated bmp
      # as the current background
      ".config/autostart/fractalart.desktop" = {
        text = ''
          [Desktop Entry]
          Name=FractalArt
          GenericName=Fractal Art
          Comment=Generate Wallpapers
          Exec=FractalArt
          Terminal=false
          Type=Application
          Categories=Graphics'';
      };
    };

    dconf.settings = {
     #set the background to the generated fractalart bmp
     "org/gnome/desktop/background" = {
       "picture-uri" = "/home/david/.fractalart/wallpaper.bmp";
     };
    };
  };
 
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    lynx
  ];

 #Steam
  programs.steam.enable = true;

 #Load fish shell and change default interactive shell (leaves scripting stuff alone)
 programs.fish.enable = true;
 users.defaultUserShell = pkgs.fish;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  
  #ensure gnome-settings daemon is running for gnome systray
  #per wiki : https://nixos.wiki/wiki/GNOME
  #services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  services.gnome.gnome-settings-daemon.enable = true;

  services.fractalart.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
 
  # rule for rpfilter to permit wireguard connections
  networking.firewall = {
   # if packets are still dropped, they will show up in dmesg
   logReversePathDrops = true;
   # wireguard trips rpfilter up
   extraCommands = ''
     ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
     ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
   '';
   extraStopCommands = ''
     ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
     ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
   '';
  };
 
  #Auto update, yo!
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;

  #Garbage collections
  nix.gc.automatic = true;
  nix.gc.dates = "03:15";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

