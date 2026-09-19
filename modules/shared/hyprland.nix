{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myHyprland;
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

    services.easyeffects.enable = true;
    # Install the "Bonus Apps" system-wide
    environment.systemPackages = with pkgs; [
      inputs.quickshell.packages.${pkgs.system}.default

      # Wayland/Hyprland core utilities
      waybar
      wofi
      waypaper
      wl-clipboard
      grim
      slurp
      hyprshot

      vlc
      yt-dlp

      libreoffice-qt
      hunspell
      hunspellDicts.uk_UA
      hunspellDicts.th_TH

      (if cfg.wallpaperEngine == "swww" then swww else hyprpaper)
    ];

    # Dotfile symlinks (still per-user via home-manager)
    home-manager.users.levi = { config, ... }: {
      xdg.configFile."hypr" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/hypr/";
        recursive = true;
      };

      xdg.configFile."quickshell" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/quickshell/";
        recursive = true;
      };
    };
  };
}
