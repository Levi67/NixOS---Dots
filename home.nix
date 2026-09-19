{ config, pkgs, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in

{
  home.username = "levi";
  home.homeDirectory = "/home/levi";
  home.stateVersion = "25.05";

  imports = [
    ./modules/services/wallust-poller.nix
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };

  # --- Dotfile symlinks (out-of-store, so edits are live without rebuild) ---
  xdg.configFile."nvim".source     = create_symlink "${dotfiles}/nvim/";
  xdg.configFile."qtile".source    = create_symlink "${dotfiles}/qtile/";
  xdg.configFile."wallust".source  = create_symlink "${dotfiles}/wallust/";
  xdg.configFile."scripts".source  = create_symlink "${dotfiles}/scripts/";
  xdg.configFile."kitty".source    = create_symlink "${dotfiles}/kitty";
  xdg.configFile."fish".source     = create_symlink "${dotfiles}/fish";
  xdg.configFile."waypaper".source = create_symlink "${dotfiles}/waypaper";

  # VSCodium: symlink just the settings and keybinds
  home.file.".config/VSCodium/User/settings.json".source    = create_symlink "${dotfiles}/vscodium/settings.json";
  home.file.".config/VSCodium/User/keybindings.json".source = create_symlink "${dotfiles}/vscodium/keybindings.json";

  # Steam speed fix
  home.file.".steam/steam/steam_dev.cfg".text = ''
    @nClientDownloadEnableHTTP2PlatformLinux 0
    @fDownloadRateImprovementToAddAnotherConnection 1.0
  '';


}
