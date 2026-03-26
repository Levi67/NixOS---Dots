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
  };

  # 2. Critical NVIDIA/Wayland Graphics Settings
  hardware.graphics = {
    enable = true;
    enable32Bit = true; 
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # 3. User-level Settings (Home Manager)
  home-manager.users.levi = {
    home.packages = with pkgs; [
      vesktop      
      lutris       
      heroic       
      mangohud     
      protonup-qt  
      vulkan-tools 
      gamescope    
    ];

    # --- ADDED: MangoHud Configuration ---
    programs.mangohud = {
      enable = true;
      enableSessionWide = false; # Only show when we launch with 'mangohud'
      settings = {

        toggle_hud = "F8";
        # Performance Metricsl
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

  # 4. Global Performance & Logic
  programs.gamemode.enable = true; 
  
  # NVIDIA Power Management Fix for 40-series cards
  # Forces the card into a higher power state when 3D apps are active
  # to prevent the "lag/stutter" when clock speeds fluctuate.
  hardware.nvidia.powerManagement.enable = false; 
}