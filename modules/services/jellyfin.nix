{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    user = "jellyfin";
    group = "media";
  };

  # Group permissions for hardware acceleration
  users.users.jellyfin.extraGroups = [ "video" "render" "media" ];

  # Shared Media Group
  users.groups.media = {};

  # Mount point
  fileSystems."/srv/jellyfin" = {
    device = "/dev/disk/by-uuid/add1298d-77ca-4722-86fb-4a498f3ca654";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
}