{ lib
, config
, ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.phil.wms;

  mkService = name: ExecStart: {
    Unit = {
      After = "graphical-session-pre.target";
      PartOf = "graphical-session.target";
    };

    Service = {
      inherit ExecStart;
      Restart = "on-abort";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
in
{
  options.phil.wms = {
    serviceCommands = mkOption {
      description = "extra commands to wrap as systemd services";
      type = types.attrsOf types.str;
      default = {};
    };
  };

  config.systemd.user.services = lib.mapAttrs mkService cfg.serviceCommands;

  imports = [
    ./udiskie.nix
    ./rofi.nix
  ];
}
