{ pkgs
, config
, lib
, net
, ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.work;
in
{
  options.phil.work = {
    enable = mkOption {
      description = "enable work module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # add config here
    home.file.".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/aws-credentials";

    home.packages = with pkgs; [
      slack
      fractal
      devdocs-desktop
      mutagen
    ];

    programs = {
      sioyek = {
        enable = true;
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
