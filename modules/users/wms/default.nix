{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.phil.wms;

  # udiskie
  commandArgs = concatStringsSep " " (map (opt: "-" + opt) [
    (if cfg.udiskie.automount then "a" else "A")
    "n"
    "T"
  ] ++ optional config.xsession.preferStatusNotifierItems "--appindicator");

  yaml = pkgs.formats.yaml { };

in {
  options.phil.wms = {
    udiskie.enable = mkEnableOption "udiskie";
    udiskie.automount = mkEnableOption "auto mount devices";
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

    xdg.configFile."udiskie/config.yml".source = yaml.generate "config.yml" {
      device_config = [
        {
          device_file = "/dev/sr0";
          ignore = true;
        }
      ];
    };
  };

  imports = [
    ./sway
    ./i3

    ./bars/polybar
    ./bars/eww
  ];
}
