{ config, pkgs, ... }:

{
  # Shared media group (levi is a member; see users.users.levi in configuration.nix)
  users.groups.media = {};

  # Auto-mount the media disk. Path kept as /srv/jellyfin for historical reasons —
  # renaming would require moving existing data on disk.
  fileSystems."/srv/jellyfin" = {
    device = "/dev/disk/by-uuid/add1298d-77ca-4722-86fb-4a498f3ca654";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
}
