{ config, lib, pkgs, ... }:

# BITTE HELFEN SIE MIR

{
  imports = [
    ./hardware-configuration.nix
    ./modules/shared/flatpak.nix
  ];

  # --- Nix ---
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    cores = 0; # Manual builds may use all available CPU threads
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
    "electron-39.8.10"
  ];

  # --- Networking ---
  networking = {
    hostName = "nixie";
    enableIPv6 = false;
    firewall.enable = true;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };

  services.resolved.enable = true; # Local DNS cache

  time.timeZone = "Europe/Berlin";

  # --- Boot & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;
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
    # "nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1;PerfLevelSrc=0x2222;PowerMizerDefaultAC=0x1;PowerMizerLevel=0x3;PowerMizerDefault=0x3"
  ];

  # --- Graphics & Desktop ---
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = false;
    xkb.layout = "de";
    videoDrivers = [ "nvidia" ];
  };

  programs.nix-ld.enable = true;

  services.displayManager.ly.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  myHyprland.enable = true; # See modules/shared/hyprland.nix

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    config.common = {
      default = [ "hyprland" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # --- NVIDIA ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true; # Recommended for 40-series cards
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      # Sync mode: NVIDIA controls the main display output.
      sync.enable = true;
      offload.enable = false;
      offload.enableOffloadCmd = false;

      # Run `lspci | grep -iE 'vga|3d'` to verify:
      # 01:00.0 -> PCI:1:0:0
      # 0b:00.0 -> PCI:11:0:0
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:11:0:0";
    };
  };

  # --- Session variables ---
  environment.sessionVariables = {
    # Wayland / Ozone
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # NVIDIA / Wayland
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    NVD_BACKEND = "direct";
    WLR_NO_HARDWARE_CURSORS = "1";

    # NVIDIA performance / caching
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_SHADER_DISK_CACHE_SIZE = "4294967296";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
  };

  # --- Users ---
  users.users.levi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "disk" "gamemode" "ydotool" "media" ];
    shell = pkgs.fish;
  };

  # --- System programs & packages ---
  programs.firefox.enable = true;
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    kitty
    hyprpolkitagent
    tree
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # --- Services & security ---
  security.polkit.enable = true;
  services.openssh.enable = true;

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "524288";
  }];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
  '';

  # --- Background auto-upgrade (game-friendly) ---
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "git+file:///home/levi/nixos-dotfiles#nixie";
    flags = [ "--update-input" "nixpkgs" ];
  };

  # Penalizes the auto-updater so it stays out of the way during games
  systemd.services.nixos-upgrade.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

  # Allows root to interact with the user-owned git repo during auto-upgrade
  programs.git.config.safe.directory = [ "/home/levi/nixos-dotfiles" ];

  # Do not change this value.
  system.stateVersion = "25.11";
}
