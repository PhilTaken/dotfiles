{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types concatStringsSep mkEnableOption optional;
  cfg = config.phil.wms.tools.udiskie;
  # udiskie
  commandArgs = concatStringsSep " " (map (opt: "-" + opt) [
      (
        if cfg.automount
        then "a"
        else "A"
      )
      "n"
      "T"
    ]
    ++ optional config.xsession.preferStatusNotifierItems "--appindicator");

  yaml = pkgs.formats.yaml {};
in {
  options.phil.wms.tools.udiskie = {
    enable = mkEnableOption "udiskie";
    automount = mkEnableOption "auto mount devices";
  };

  config = {
    systemd.user.services.udiskie = mkIf cfg.enable {
      Unit = {
        Description = "udiskie mount daemon";
        #Requires = [ "tray.target" ];
        After = ["graphical-session-pre.target"]; # "tray.target" ];
        PartOf = ["graphical-session.target"];
      };

      Service = {ExecStart = "${pkgs.udiskie}/bin/udiskie ${commandArgs}";};
      Install = {WantedBy = ["graphical-session.target"];};
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
}
