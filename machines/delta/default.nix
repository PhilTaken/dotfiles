{ pkgs, ... }:
{
  imports = [ ./configuration.nix ];

  phil.server.services.telegraf.inputs.extrasensors = false;
  phil.fileshare.shares.dirs = [ "/media" ];
}
