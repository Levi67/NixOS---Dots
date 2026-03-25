{ config, lib, pkgs, ... }:

let
  cfg = config.myHyprland; # This is our custom 'namespace'
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in {
  # 1. Define the "Options" (The toggle switch)
  options.myHyprland = {
    enable = lib.mkEnableOption "Levi's Hyprland Suite";
    
    # You can even add custom sub-options!
    wallpaperEngine = lib.mkOption {
      type = lib.types.enum [ "swww" "hyprpaper" ];
      default = "swww";
    };
  };

  # 2. Define the "Config" (What happens when enabled)
  config = lib.mkIf cfg.enable {
    # Install the "Bonus Apps"
    home.packages = with pkgs; [
      waypaper
      waybar
      wofi
      grim
      slurp
      wl-clipboard
      (if cfg.wallpaperEngine == "swww" then swww else hyprpaper)
    ];

    # Apply your symlinks automatically
    xdg.configFile."hypr" = {
      source = create_symlink "${dotfiles}/hypr/";
      recursive = true;
    };
  };
}