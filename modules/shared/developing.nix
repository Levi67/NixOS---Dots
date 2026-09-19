{ pkgs, config, inputs, ... }:

{
  programs.adb.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk; # Latest LTS version
  };

  environment.systemPackages = with pkgs; [
    # Editors / IDEs
    neovim
    vscodium

    # Language toolchains
    nodejs
    gcc
    jdk25

    # Nix tooling
    nil
    nixpkgs-fmt

    # CLI utilities
    ripgrep
    jq
    python3

    # Git UIs / AI tools
    gitkraken
    # claude-code
  ];
}
