{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.phil.wms;

  # udiskie
  commandArgs = concatStringsSep " " (map (opt: "-" + opt) [
    "a"
    "n"
    "T"
  ] ++ optional config.xsession.preferStatusNotifierItems "--appindicator");
in {
  options.phil.wms = {
    udiskie.enable = mkEnableOption "udiskie";
    bars.barcommand = mkOption {
      description = "comand to (re)start the bar(s)";
      type = types.str;
      default = "";
    };
  };

  config = {
    systemd.user.services.udiskie = mkIf (cfg.udiskie.enable) {
      Unit = {
        Description = "udiskie mount daemon";
        #Requires = [ "tray.target" ];
        After = [ "graphical-session-pre.target" ]; # "tray.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = { ExecStart = "${pkgs.udiskie}/bin/udiskie ${commandArgs}"; };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };

  imports = [
    ./sway
    ./i3

    ./bars/polybar
    ./bars/eww
  ];
}
