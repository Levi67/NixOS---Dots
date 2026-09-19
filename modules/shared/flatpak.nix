{ config, pkgs, ... }:

{
  # 1. Enable the Flatpak Service (Flathub repo is added below)
  services.flatpak.enable = true;

  # 2. Automatically add the Flathub Repository
  # This saves you from having to run the manual terminal command
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # 3. Expose Flatpak's exports on XDG_DATA_DIRS so .desktop entries appear
  environment.extraInit = ''
    export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
  '';

  # Note: xdg.portal (needed for Flatpak file pickers, links, etc.) is
  # configured centrally in configuration.nix.
}
