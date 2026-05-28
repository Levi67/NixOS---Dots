{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/shared/flatpak.nix
  ];

  # --- Nix Package Manager & Garbage Collection Settings ---
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    # Allows MANUAL builds to use all available CPU threads automatically
    cores = 0; 
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];

  # --- Networking & DNS ---
  networking.hostName = "nixie";
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;

  # Local dns cache
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  time.timeZone = "Europe/Berlin";

  # --- Bootloader & Kernel Configuration ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest Zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "vm.max_map_count" = 2147483642; # The "Steam Deck" value
  };

  boot.kernelParams = [ 
    "vsyscall=emulate"      # Fixes the PioneerGame.exe vsyscall read denied (CRITICAL)
    "clearcpuid=514"        # Disables UMIP (fixes the errors from your previous log)
    "split_lock_detect=off" # Stops GameMode from failing and fixes related stutters
    "nvidia_drm.fbdev=1" 
    "nvidia_drm.modeset=1"
    # Forces the NVIDIA card to stay awake and sync properly
    "nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1;PerfLevelSrc=0x2222;PowerMizerDefaultAC=0x1;PowerMizerLevel=0x3;PowerMizerDefault=0x3"
  ];

  # --- Graphics & Desktop Environment ---
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = false;
    xkb.layout = "de";
    videoDrivers = [ "nvidia" ]; # Load NVIDIA driver for Xorg and Wayland
  };

  services.displayManager.ly.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; 
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
    open = true; # Recommended for 40-series cards
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      sync.enable = true;
      offload.enable = false;
      offload.enableOffloadCmd = false;

      # Bus IDs
      nvidiaBusId = "PCI:1:0:0";  # 01:00.0
      amdgpuBusId = "PCI:11:0:0"; # 0b:00.0
    };
  };

  # --- Environment & Session Variables ---
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Forces Electron/Chromium apps (like Steam UI) to use Wayland
  
    # Required for NVIDIA Wayland
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  
    # XDG Desktop configurations
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    WLR_NO_HARDWARE_CURSORS = "1"; # Fixes invisible cursors on some NVIDIA setups

    WLR_DRM_NO_ATOMIC = "1";

    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_SHADER_DISK_CACHE_SIZE = "4294967296"; # 4GB in bytes

    GBM_BACKEND = "nvidia-drm";
    __GL_GSYNC_ALLOWED = "0"; # Disable G-Sync (massive source of flickers on Linux)
    __GL_VRR_ALLOWED = "0";   # Disable VRR
    
    NVD_BACKEND = "direct";   # Required for the "ghosting" fix
  };

  # --- User Configurations & System Packages ---
  users.users.levi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "disk" "gamemode" ];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.fish;
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk; # Latest LTS version
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    kitty
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # --- System Services ---
  services.openssh.enable = true;
  services.flatpak.enable = true;

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "524288";
  }];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
  '';

  # --- Background Automated Upgrades (Game-Optimized) ---
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "git+file:///home/levi/nixos-dotfiles#nixie";
    flags = [
      "--update-input"
      "nixpkgs"
    ];
  };

  # Penalizes the background auto-updater so it stays out of your way during games
  systemd.services.nixos-upgrade.serviceConfig = {
    Nice = 19;                  # Lowest possible CPU priority
    IOSchedulingClass = "idle"; # Only uses disk bandwidth if the system is completely idle
  };

  # Allows root to interact with your user-owned git repo during auto-upgrade
  programs.git.config.safe.directory = [ "/home/levi/nixos-dotfiles" ];

  # Do not change this value.
  system.stateVersion = "25.11"; 
}