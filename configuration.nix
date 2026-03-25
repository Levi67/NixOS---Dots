{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixie";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; 
  };

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = false;
    xkb.layout = "de";
    # Load nvidia driver for Xorg and Wayland
    videoDrivers = ["nvidia"];
  };

  services.displayManager.ly.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # --- NVIDIA Settings ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # Recommended for 40-series cards
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  environment.sessionVariables = {
    # Forces Electron/Chromium apps (like Steam's UI) to use Wayland
    NIXOS_OZONE_WL = "1";
  
    # Required for NVIDIA Wayland
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  
    # Tell XDG which session we are in (helps Wofi/Launchers)
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # Fixes invisible cursors on some NVIDIA setups
    WLR_NO_HARDWARE_CURSORS = "1"; 
  };
  # -----------------------

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    # config.common.default = "*"; # Optional: helps if apps take 30s to open
  };

  users.users.levi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
#    git
    kitty
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;

  system.stateVersion = "25.11"; 
}