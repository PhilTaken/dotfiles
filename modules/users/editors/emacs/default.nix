{ pkgs
, config
, lib
, inputs
, ...
}:
with lib;

let
  cfg = config.phil.editors.emacs;
in
{
  imports = [
    inputs.nix-doom-emacs.hmModule
  ];

  options.phil.editors.emacs = {
    enable = mkOption {
      description = "enable emacs module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ./doom.d;
    };

    services.emacs.enable = true;
  };
}
