{ pkgs
, config
, lib
, net
, ...
}:
with lib;

let
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

    # TODO: maybe move parts of this to delta?
    services.hound = {
      enable = true;
      repositories = {
        serokell-nix = {
          url = "https://www.github.com/serokell/serokell.nix";
          ms-between-poll = 20000;
        };
        nixpgks = {
          url = "https://www.github.com/nixos/nixpkgs";
          ms-between-poll = 20000;
        };
        dotfiles.url = "https://gitea.${net.tld}/phil/dotfiles";
      };
    };

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
