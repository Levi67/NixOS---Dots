{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };



  



  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

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
    open = true; # Keep this true for 40-series
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # Force NVIDIA to be the main GPU (fixes the AMD iGPU takeover)
    prime = {
      sync.enable = true;
      # Use lspci to verify these IDs! (e.g., 01:00.0 becomes "PCI:1:0:0")
      # 01:00.0 becomes PCI:1:0:0
      nvidiaBusId = "PCI:1:0:0";
      # 0b:00.0 becomes PCI:11:0:0 (0b in hex is 11 in decimal)
      amdgpuBusId = "PCI:11:0:0";
    };
  };


  # Force the environment to prefer NVIDIA for all Vulkan apps
  environment.variables = {
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  };

environment.sessionVariables = {
    # Forces Electron/Chromium apps (like Steam's UI) to use Wayland
    NIXOS_OZONE_WL = "1";
  
    # Required for NVIDIA Wayland
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Ensure this only appears ONCE
  
    # Tell XDG which session we are in
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # Fixes invisible cursors
    WLR_NO_HARDWARE_CURSORS = "1"; 

    # On 25.11, the path usually looks like this
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    
    # Force Gamescope to use X11 backend to avoid the Wayland input crash
    SDL_VIDEODRIVER = "x11";
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
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  programs.fish.enable = true;

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