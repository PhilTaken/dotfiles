{ pkgs, ...}:
{
  imports = [ ./configuration.nix ];
  phil.fileshare.mount.binds = [{
    host = "beta";
    dirs = [ "/media" ];
  }];
}
