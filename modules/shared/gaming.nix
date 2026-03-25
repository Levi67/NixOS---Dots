{ pkgs, ... }:

{
  # 1. System-level Steam & Gaming Settings
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    
    # This automatically adds proton-ge to Steam's compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # 2. Critical NVIDIA/Wayland Graphics Settings
  # (Steam needs these 32-bit and VA-API packages to avoid crashing)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam (32-bit client)
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # 3. User-level Gaming Packages
  home-manager.users.levi = {
    home.packages = with pkgs; [
      vesktop      # Discord with Wayland screensharing support
      lutris       # For GOG/Epic/Ubisoft games
      heroic       # Great Epic/GOG launcher
      mangohud     # FPS/Performance overlay
      protonup-qt  # GUI to manage Proton versions easily
      vulkan-tools # Helpful for debugging ('vulkaninfo')
      gamescope    # Micro-compositor (use with: gamescope -f -- steam)
    ];
  };

  # 4. Global Performance & Logic
  programs.gamemode.enable = true; # Optimizes CPU/GPU for games
}