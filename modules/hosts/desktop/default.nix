{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.desktop;
in
{
  options.phil.desktop = {
    enable = mkOption {
      description = "enable desktop module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    programs.steam.enable = true;
    environment.systemPackages = with pkgs; [
      audacity
      chromium
      citra
      multimc
      obs-studio
      citra
      openttd
    ];

  };
}

