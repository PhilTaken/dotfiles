{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.phil.zellij;
  settings = import ./config.nix { inherit pkgs cfg; };
  inherit (lib) mkOption mkIf types mkEnableOption;
in
{
  options.phil.zellij = {
    enable = mkEnableOption "zellij";
    defaultShell = mkOption {
      type = types.nullOr (types.enum [ "fish" "zsh" ]);
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.zellij
    ];

    xdg.configFile."zellij/config.kdl" = {
      source = settings.configFile;
    };

    xdg.configFile."zellij/layouts" = {
      source = pkgs.stdenv.mkDerivation {
        pname = "zellij-layouts";
        version = "0.1";
        phases = [ "patchPhase" ];

        src = ./layouts;

        # TODO: replace commands with actual paths to binaries
        patchPhase = ''
          mkdir -p $out
          cp -r $src/* $out

          substituteInPlace $out/default.kdl \
            --replace '@user@' '${config.home.username}'

          substituteInPlace $out/vortrag.kdl \
            --replace '@user@' '${config.home.username}'
        '';
      };
      recursive = true;
    };
  };
}
