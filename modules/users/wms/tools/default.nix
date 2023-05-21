{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  cfg = config.phil.wms;

  mkService = name: value: let
    extraAttrs =
      if builtins.typeOf value == "string"
      then {}
      else value;
    ExecStart =
      if builtins.typeOf value == "string"
      then value
      else extraAttrs.Service.ExecStart;
  in
    lib.recursiveUpdate {
      Unit.PartOf = "graphical-session.target";
      Install.WantedBy = ["graphical-session.target"];

      Service = {
        inherit ExecStart;
        Restart = "on-abort";
      };
    }
    extraAttrs;
in {
  options.phil.wms = {
    serviceCommands = mkOption {
      description = "extra commands to wrap as systemd services";
      type = types.attrsOf (types.either types.str (types.attrsOf types.anything));
      default = {};
    };
  };

  config.systemd.user.services = lib.mapAttrs mkService cfg.serviceCommands;

  imports = [
    ./udiskie.nix
    ./rofi.nix
  ];
}
