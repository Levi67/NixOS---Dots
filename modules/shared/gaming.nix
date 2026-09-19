{ pkgs, ... }:

{
  # 1. System-level Steam & Gaming Settings
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Automatically adds proton-ge to Steam's compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    extraPackages = with pkgs; [
      gamemode
      mangohud
    ];
  };

  # 2. Gaming-relevant VA-API drivers (base graphics stack is set in configuration.nix)
  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  # 3. Global Performance & Logic
  programs.gamemode.enable = true;

  # Forces Hyprland to support X11 windows
  programs.xwayland.enable = true;

  # 4. System-wide gaming packages
  environment.systemPackages = with pkgs; [
    vesktop
    lutris
    heroic
    mangohud
    protonup-qt
    vulkan-tools
    gamescope

    hyprshade

    # modrinth-app

    faugus-launcher

    ryubing

    (prismlauncher.override {
      jdks = [
        jdk8         # For old versions
        jdk17        # For 1.18 - 1.20
        jdk21        # For 1.20.5+
        jdk25        # For the newest versions
      ];
    })
    # jdk25_headless

    # Nintendo DS Emulator
    desmume
  ];

  # 5. MangoHud config still lives per-user (no system-level equivalent exists)
  home-manager.users.levi = {
    programs.mangohud = {
      enable = true;
      enableSessionWide = false; # Only show when we launch with 'mangohud'
      settings = {
        toggle_hud = "F8";

        fps_limit = 144;

        # Performance Metrics
        fps = true;
        frametime = true;
        frame_timing = true;
        gpu_stats = true;
        gpu_temp = true;
        cpu_stats = true;
        cpu_temp = true;
        vram = true;
        ram = true;

        # Visuals (Catppuccin Mocha-ish)
        legacy_layout = false;
        horizontal = false;
        round_corners = 10;
        background_alpha = 0.5;
        font_size = 24;

        # Colors
        text_color = "CDD6F4";
        gpu_color = "A6E3A1";
        cpu_color = "89B4FA";
        vram_color = "F5C2E7";
      };
    };
  };
}
