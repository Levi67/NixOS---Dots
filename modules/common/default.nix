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

    # Import home-specific config
    imports = [
      ../../home.nix
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

  # Cursor session variables (rest of NVIDIA/Wayland vars live in configuration.nix)
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
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

  services.gnome.gnome-keyring.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    psmisc
    bibata-cursors

    fastfetch
    tty-clock
    pavucontrol

    nautilus

    htop
    dua

    zellij

    anki-bin

    wineWowPackages.stable

    gimp-with-plugins

    polkit_gnome

    # notion-app-enhanced

    wallust

    remmina

    inotify-tools

    unzip
    unrar

    ydotool

    wootility

    rquickshare

    # Display settings
    nwg-displays
    wlr-randr  # Required backend for nwg-displays to talk to Wayland

    (enpass.overrideAttrs (oldAttrs: rec {
      version = "6.11.13.1957";
      src = fetchurl {
        url = "https://apt.enpass.io/pool/main/e/enpass/enpass_${version}_amd64.deb";
        hash = "sha256-LYyQZDhRWRr/QQV7OAp+h7uDm/XFqgyhRWFE6ZlskCo=";
      };
    }))
  ];

  programs.ydotool.enable = true;
}
