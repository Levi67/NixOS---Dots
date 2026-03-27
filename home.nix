{ config, pkgs, lib, ... }:

let

  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

in



{
	home.username = "levi";
	home.homeDirectory = "/home/levi";
	programs.git.enable = true;
	home.stateVersion = "25.05";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use nixos, btw";
		};
  };
  
#	home.file.".config/nvim".source = ./config/nvim;


  xdg.configFile."nvim" = {
    source = create_symlink "${dotfiles}/nvim/";
#    recursive = true;
  };


  
  
  xdg.configFile."qtile" = {
    source = create_symlink "${dotfiles}/qtile/";
#    recursive = true;
  };

  xdg.configFile."wallust" = {
    source = create_symlink "${dotfiles}/wallust/";
#    recursive = true;
  };

  xdg.configFile."scripts" = {
    source = create_symlink "${dotfiles}/scripts/";
#    recursive = true;
  };



  # Add these to your home.nix
  xdg.configFile."kitty".source = create_symlink "${dotfiles}/kitty";
  xdg.configFile."fish".source = create_symlink "${dotfiles}/fish";
  xdg.configFile."waypaper".source = create_symlink "${dotfiles}/waypaper";

  # Symlink just the settings and keybinds | Keybindings
  home.file.".config/VSCodium/User/settings.json".source = create_symlink "${dotfiles}/vscodium/settings.json";
  home.file.".config/VSCodium/User/keybindings.json".source = create_symlink "${dotfiles}/vscodium/keybindings.json";


  imports = [
    ./modules/shared/hyprland.nix
  ];


  # Steam speed fix
  home.file.".steam/steam/steam_dev.cfg".text = ''
    @nClientDownloadEnableHTTP2PlatformLinux 0
    @fDownloadRateImprovementToAddAnotherConnection 1.0
    '';





  myHyprland.enable = true;


  /*
  xdg.configFile."hypr" = {
    source = create_symlink "${dotfiles}/hypr/"; 
    recursive = true;
  };
  */






	home.packages = with pkgs; [ 
		neovim
		ripgrep
		nil
		nixpkgs-fmt
		nodejs
		gcc




    # Hyprland stuff
    
#    hyprland

    waybar
    swww
    grim
    slurp
    wl-clipboard
    wofi
	];
  


}
