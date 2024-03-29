{
  pkgs,
  config,
  lib,
  inputs,
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
      #termscp

      bottom
      fd
      file
      eza
      gnupg
      iperf
      duf

      pre-commit

      nebula

      rsync
      wget
      #whois
      fswatch

      httpie
      hurl

      sad

      hound

      git
      #copier

      (pkgs.writeShellScriptBin "essh" ''
        git_basedir=$(git rev-parse --show-toplevel 2>/dev/null)

        if [ $? != 0 ]; then
          echo "not in a deployment/git repo: $PWD"
          exit 1
        fi

        cd $git_basedir
        test -d "deployment/" && cd "deployment/"

        tld=$(rg "host_domain" environments/ -IN | cut -d " " -f 3 | uniq)
        if [ "$tld" != "fcio.net" ]; then
          echo "warning: tld != fcio.net: $tld"
        fi

        host=$(${pkgs.ripgrep}/bin/rg "\[host:" environments/ -IN |\
          cut -d ":" -f 2 |\
          cut -d "]" -f 1 |\
          sk --height 10% --no-clear-start)

        if [ ! -z "$host" ]; then
          echo "connecting to $host.$tld ..."
          ssh $host.$tld $@
        fi
      '')

      (pkgs.writeShellScriptBin "envssh" ''
        git_basedir=$(git rev-parse --show-toplevel 2>/dev/null)

        if [ $? != 0 ]; then
          echo "not in a deployment/git repo: $PWD"
          exit 1
        fi

        cd $git_basedir

        test -d "deployment/" && cd "deployment/"
        env=$(ls environments/ | sk --height 10% --no-clear-start)
        tld=$(rg "host_domain" environments/$env/ -IN | cut -d " " -f 3)

        if [ ! -z "$env" ]; then
          ${pkgs.ripgrep}/bin/rg "\[host:" environments/$env/ -IN |\
            cut -d ":" -f 2 |\
            cut -d "]" -f 1 |\
            xargs -I % sh -c "echo \"connecting to %.$tld:\"; ssh %.$tld $@ | sed 's/^/%> /'"
        fi
      '')

      (pkgs.writeShellScriptBin "fix-ssh-keys" ''
        envssh exit
      '')

      # time tracker
      inputs.ttrack.packages.${pkgs.system}.ttrack
      inputs.dimsum.packages.${pkgs.system}.dimsum-release
      inputs.fc-utils.packages.${pkgs.system}.default
      inputs.devenv.packages.${pkgs.system}.default

      age
      lsyncd

      glab

      # _1password
    ];

    home.shellAliases = {
      b = "${inputs.fc-utils.packages.${pkgs.system}.default}/bin/fc-utils";
      # the ssh module should not be enabled on workstations
      s = "ssh $(cat ~/.ssh/known_hosts | cut -d ' ' -f 1 | sort | uniq | ${pkgs.skim}/bin/sk)";
    };

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
