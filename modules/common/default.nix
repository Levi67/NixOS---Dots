{ pkgs, config, inputs, ... }:

let
  # Helper to access themes and extensions
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in

{
  imports = [ 
    inputs.spicetify-nix.nixosModules.default 
    # Ensure Home Manager is imported here if it's not in your main configuration.nix
  ];

  # 1. THE CURSOR FIX (Home Manager Section)
  # This fixes the cursor for GTK, X11 (Steam), and Wayland apps
  home-manager.users.levi = {
    home.stateVersion = "25.05"; # Adjust to your current NixOS version
    
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

  # 2. STABILITY FIX (Session Variables)
  # This prevents Steam/Wofi from crashing Hyprland on NVIDIA
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
    # Ensure Wayland is forced for Electron apps
    NIXOS_OZONE_WL = "1";
    # Crucial for NVIDIA cursors not disappearing
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # 3. Setup Spicetify
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

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    vscodium
    psmisc
    bibata-cursors # Added to system packages
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