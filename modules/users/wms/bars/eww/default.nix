{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.wms.bars.eww;
in {
  options.phil.wms.bars.eww = {
    enable = mkOption {
      description = "enable eww module";
      type = types.bool;
      default = false;
    };

    enableWayland = mkOption {
      description = "build wayland package";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    phil.wms.bars.barcommand = "eww open bar";

    home.packages = with pkgs; [
      kde-gtk-config
    ];

    programs.eww = {
      enable = true;
      package = if cfg.enableWayland then pkgs.eww-git-wayland else pkgs.eww-git;
      configDir = (pkgs.stdenv.mkDerivation rec {
        pname = "eww-configfolder";
        version = "0.1";

        src = ./config;

        # TODO: replace commands with actual paths to binaries
        buildPhase = ''
        '';

        installPhase = ''
          mkdir -p $out
          cp -r $src/* $out
        '';
      });
    };

    systemd.user.services.eww-bar = {
      Unit = {
        Description = "Unit for the eww daemon";
        After = "graphical-session-pre.target";
        PartOf = "graphical-session.target";
      };

      Service = let
        eww = "${inputs.config.programs.eww.package}/bin/eww";
      in {
        ExecStart = ''
          ${eww} --no-daemonize daemon
        '';
        Restart = "on-abort";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
