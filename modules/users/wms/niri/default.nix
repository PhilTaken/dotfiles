{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.phil.wms.niri;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.phil.wms.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    # TODO re-enable + merge with json?
    stylix.targets.noctalia-shell.enable = false;

    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      # update these with `noctalia-shell ipc call state all | jq -S .settings | wl-copy`
      settings = ./noctalia-settings.json;
    };

    programs.alacritty.enable = true; # Super+T in the default setting (terminal)
    programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
    programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
    services.mako.enable = true; # notification daemon
    services.swayidle.enable = true; # idle management daemon
    services.polkit-gnome.enable = true; # polkit
  };
}
