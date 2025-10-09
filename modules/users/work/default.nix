{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.work;

  op_gpg_sign_program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM59Wr25vmNWuyzgBXsQJvhd4EObMFRiJGbnbC0Jt/9I";
in
{
  options.phil.work = {
    enable = mkEnableOption "work";
  };

  # wip
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mutagen
      #termscp

      awscli2
      bottom
      fd
      file
      eza
      gnupg
      iperf
      duf

      nebula

      rsync
      wget
      #whois
      fswatch

      httpie
      hurl

      git
      uv
      python311
      openssl
      rclone
      pre-commit

      magic-wormhole
      lnav

      sad

      #copier

      # TODO RIIR (the entire thing, using tantivy)
      (pkgs.writeShellScriptBin "houndd" ''
        mkdir -p $XDG_CACHE_HOME/houndd && cd $XDG_CACHE_HOME/houndd

        echo "regenerating config file!"

        for repo in $(git workspace list --full); do
            pushd $repo >/dev/null;
            remote=$(git remote -v | head -1 | awk '{print $2}');
            popd >/dev/null;
            echo "$repo $remote"
        done > repos.txt
        REPOFILE=$PWD/repos.txt nix eval -f ${./gen_houndd_config.nix} --json | jq > config.json

        echo "done, starting houndd!"

        exec ${pkgs.hound}/bin/houndd $@
      '')

      (pkgs.writeShellScriptBin "essh" ''
        git_basedir=$(git rev-parse --show-toplevel 2>/dev/null)

        if [ $? != 0 ]; then
          echo "not in a deployment/git repo: $PWD"
          exit 1
        fi

        cd $git_basedir
        test -d "deployment/" && cd "deployment/"

        tld=$(rg "host_domain" environments/ -IN | cut -d " " -f 3 | uniq)

        host=$(${pkgs.ripgrep}/bin/rg "\[host:" environments/ -IN |\
          cut -d ":" -f 2 |\
          cut -d "]" -f 1 |\
          sk --height 10% --no-clear-start)

        if [ ! -z "$host" ]; then
          echo "connecting to $host.$tld ..." >&2
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

      (pkgs.writeShellScriptBin "fc-du" ''
        tmpfile=$(${pkgs.uutils-coreutils}/bin/uutils-mktemp --suffix .svg)

        ssh $1 "nix-shell -p nix-du --run \"nix-du -s 100M\"" | ${pkgs.graphviz}/bin/dot -Tsvg > $tmpfile
        open $tmpfile
      '')

      # time tracker
      #inputs.ttrack.packages.${pkgs.system}.ttrack
      #inputs.dimsum.packages.${pkgs.system}.dimsum-release
      #inputs.fc-utils.packages.${pkgs.system}.default
      #inputs.devenv.packages.${pkgs.system}.default

      age
      lsyncd

      # git(hub|lab) cli tools
      glab
      gh

      # _1password
    ];

    # ensure ssh is available
    # phil.ssh.enable = true;
    home.shellAliases = {
      b = "${inputs.fc-utils.packages.${pkgs.system}.default}/bin/fc-utils";
      s = "ssh $(cat ~/.ssh/known_hosts | cut -d ' ' -f 1 | sort | uniq | ${pkgs.skim}/bin/sk)";
    };

    programs.jujutsu.settings = {
      "--scope" = [
        {
          "--when".repositories = [ "${config.home.sessionVariables.GIT_WORKSPACE}/" ];
          user = {
            email = "ph@flyingcircus.io";
            name = "Philipp Herzog";
          };
          signing = {
            backend = "ssh";
            key = ssh_key;
            backends.ssh.program = op_gpg_sign_program;
          };
        }
      ];
    };

    programs.git = {
      includes = [
        {
          condition = "gitdir:${config.home.sessionVariables.GIT_WORKSPACE}/";
          contents = {
            gpg.format = "ssh";
            gpg.ssh.program = op_gpg_sign_program;
            user = {
              email = "ph@flyingcircus.io";
              name = "Philipp Herzog";
              signingKey = ssh_key;
            };
          };
        }
      ];

      extraConfig.diff = {
        gpg = {
          textconv = "gpg -q --no-tty --decrypt";
          binary = true;
        };

        age = {
          textconv = "batou secrets decrypttostdout";
        };
      };

      attributes = [
        "environments/*/*.age diff=age"
        "environments/*/*.age-diffable diff=age"
      ];
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
