{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.terminals;
in
rec {
  options.phil.terminals = {
    default_font = mkOption {
      description = "default font";
      type = types.str;
      default = "Iosevka Comfy";
    };
  };

  config = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          font.normal.family = cfg.default_font;
          font.size = 13;
          env.TERM = "xterm-256color";
        };
      };
    };

    xdg.configFile."foot/foot.ini".text = ''
      font=${cfg.default_font}:size=13
      bold-text-in-bright=yes
      dpi-aware=yes

      [url]
      launch=firefox ''${url}
      osc8-underline=always
    '';

    xdg.configFile."wezterm".source = ./wezterm;

    home.packages = with pkgs; [
      foot
      wezterm
    ];
  };
}
