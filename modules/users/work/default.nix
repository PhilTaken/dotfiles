{ pkgs
, config
, lib
, net
, ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.work;
in
{
  options.phil.work = {
    enable = mkEnableOption "work";
  };

  # wip
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devdocs-desktop
      mutagen
    ];

    programs = {
      sioyek = {
        enable = false;
      };
    };

    systemd.user.services.mutagen-daemon = {
      Unit = {
        Description = "Unit for the mutagen daemon";
        After = "graphical-session-pre.target";
        PartOf = "graphical-session.target";
      };

      Service = {
        ExecStart = "${pkgs.mutagen}/bin/mutagen daemon start";
        Restart = "on-abort";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
