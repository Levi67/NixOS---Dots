{ config, pkgs, ... }:

{
  systemd.user.services.wallust-poller = {
    Unit = {
      Description = "Wallust Wallpaper Poller";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ]; # Note: Capital 'O' in PartOf
    };

    Service = {
      Type = "simple";
      # This uses the literal string path to your script
      ExecStart = "${config.home.homeDirectory}/.config/scripts/swww-wallust-executer.sh";
      Restart = "always";
      RestartSec = 3;
      PassEnvironment = [ "DISPLAY" "WAYLAND_DISPLAY" "XDG_RUNTIME_DIR" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}