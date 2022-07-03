{ pkgs, ... }:
{
  imports = [ ./configuration.nix ];

  phil.server.services.telegraf.inputs.extrasensors = true;
  phil.fileshare.shares.dirs = [ "/media" ];
}
