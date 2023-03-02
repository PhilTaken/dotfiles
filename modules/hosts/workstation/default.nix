{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf types;
  cfg = config.phil.workstation;
in
{
  options.phil.workstation = {
    enable = mkEnableOption "workstation";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      #vlc
      #calibre
      #foliate
      #pdfsam-basic
      #xournalpp
      #baobab
      xfce.thunar

      webcord
      #obsidian

      tg
    ];
  };
}

