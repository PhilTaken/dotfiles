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
      copier

      (pkgs.writeShellScriptBin "essh" ''
        tld=$(rg "host_domain" environments/ -IN | cut -d " " -f 3 | uniq)
        if [ "$tld" != "fcio.net" ]; then
          echo "warning: tld != fcio.net: $tld"
        fi

        host=$(${pkgs.ripgrep}/bin/rg "\[host:" environments/ -IN |\
          cut -d ":" -f 2 |\
          cut -d "]" -f 1 |\
          sk)

        if [ ! -z "$host" ]; then
          echo "connecting to $host.$tld ..."
          ssh $host.$tld $@
        fi
      '')

      (pkgs.writeShellScriptBin "envssh" ''
        env=$(ls environments/ | sk)
        tld=$(rg "host_domain" environments/$env/ -IN | cut -d " " -f 3)

        if [ ! -z "$env" ]; then
          ${pkgs.ripgrep}/bin/rg "\[host:" environments/$env/ -IN |\
            cut -d ":" -f 2 |\
            cut -d "]" -f 1 |\
            xargs -I host ssh host.$tld $@
        fi
      '')

      (pkgs.writeShellScriptBin "fix-ssh-keys" ''
        envssh exit
      '')

      age

      # _1password
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
