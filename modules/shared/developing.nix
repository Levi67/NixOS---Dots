{ pkgs, config, inputs, ... }:


{


  programs.adb.enable = true;



  # System Packages
  environment.systemPackages = with pkgs; [

  ];
}