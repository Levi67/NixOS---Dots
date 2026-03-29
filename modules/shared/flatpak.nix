{ config, pkgs, ... }:

{
  # 1. Enable the Flatpak Service
  services.flatpak.enable = true;

  # 2. Fix for Hyprland / Wayland (Portals)
  # Flatpaks need these to open file pickers and handle links
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-hyprland 
      pkgs.xdg-desktop-portal-gtk 
    ];
    config.common.default = "*";
  };

  # 3. Automatically add the Flathub Repository
  # This saves you from having to run the manual terminal command
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  environment.extraInit = ''
  export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
    '';


}