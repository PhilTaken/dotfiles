{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.work;
in {
  options.phil.work = {
    enable = mkEnableOption "work";
  };

  # wip
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mutagen
      termscp

      bottom
      fd
      file
      exa
      gnupg
      iperf

      pre-commit

      rsync
      wget
      whois
      fswatch

      httpie
      termscp

      git
    ];

    programs = {
      sioyek.enable = false;
      watson = {
        enable = true;
        settings = {
          options = {
            stop_on_start = true;
            stop_on_restart = false;
            date_format = "%Y-%m-%d";
            time_format = "%H:%M:%S%z";
            week_start = "monday";
            pager = false;
            reverse_log = true;

            log_current = false;
            report_current = false;
          };
        };
      };
    };
  };
}
