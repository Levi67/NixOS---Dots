{ pkgs, config, inputs, ... }:

let
  # Helper to access themes and extensions
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in

{
  imports = [ 
    inputs.spicetify-nix.nixosModules.default 
  ];

  # User Configuration (Home Manager)
  home-manager.users.levi = { config, ... }: {
    home.stateVersion = "25.05";

    # Import other home-specific modules
    imports = [
      ../../home.nix
      ../shared/hyprland.nix
    ];

    # Git Configuration
    programs.git = {
      enable = true;
      userName = "Levi";
      userEmail = "levisuper@gmx.de";
      extraConfig = {
        include.path = "${config.home.homeDirectory}/nixos-dotfiles/config/git/config";
      };
    };

    # Cursor & Theme Fixes
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
      };
    };
  };

  # System-wide Session Variables (NVIDIA stability)
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Spicetify (System level)
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
      hidePodcasts
      fullAppDisplay
    ];
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    vscodium
    psmisc
    bibata-cursors
    fish
    gitkraken
    
    (enpass.overrideAttrs (oldAttrs: rec {
      version = "6.11.13.1957"; 
      src = fetchurl {
        url = "https://apt.enpass.io/pool/main/e/enpass/enpass_${version}_amd64.deb";
        hash = "sha256-LYyQZDhRWRr/QQV7OAp+h7uDm/XFqgyhRWFE6ZlskCo="; 
      };
    }))
  ];
}