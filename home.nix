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
