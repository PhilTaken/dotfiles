{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.arm;

  armpy = pkgs.python3.withPackages (ps: with ps; [
    (buildPythonPackage rec {
      pname = "robobrowser";
      version = "0.5.3";
      propagatedBuildInputs = [ requests werkzeug six beautifulsoup4 tox sphinx nose mock coveralls ];
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-MSGayrQcporc6SjlweBKzrukzqvrRHucXkCNezD+6YM=";
      };
      doCheck = false;
    })
    (buildPythonPackage rec {
      pname = "pydvdid";
      version = "1.0";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-EQod1k6CJnzmEvUgylfYvCFHeTXnWIIwMlbR9M0vEws=";
      };
    })
    (buildPythonPackage rec {
      pname = "tinydownload";
      version = "0.1.0";
      format = "wheel";
      propagatedBuildInputs = [ requests beautifulsoup4 ];
      src = fetchPypi {
        inherit pname version format;
        sha256 = "sha256-jdkuzoe7V/GoGtlzzt15q7GxFHh8RhqRaM0AP2QPLy0=";
      };
    })
    markdown
    pycurl
    requests
    urllib3
    xmltodict
    pyudev
    pyyaml
    flask
    flask_wtf
    flask_sqlalchemy
    flask_migrate
    flask-cors
    psutil
    netifaces
    flask_login
    apprise
    bcrypt
    musicbrainzngs
    discid
    prettytable
  ]);

  raw_arm_src = pkgs.fetchFromGitHub {
    repo = "automatic-ripping-machine";
    owner = "automatic-ripping-machine";
    rev = "cf5fbed48613b3711ac35a255bc51dcb69e61a40";
    sha256 = "sha256-P0pRiYv9n4nxNPruLc67RHV8Oo/qA47JiHRcBw2PCIQ=";
  };

  arm-src = pkgs.runCommandLocal "arm-src" { src = raw_arm_src; } ''
    mkdir -p $out
    cp -r $src/* $out
    cp ${cfg.configFile} $out/arm.yaml
  '';

  arm-core = pkgs.runCommandLocal "arm-core.sh" { } ''
    substitute ${./arm_wrapper.sh} $out                       \
      --replace @configFile@ ${cfg.configFile}                \
      --replace @pythonpath@ ${arm-src}/                      \
      --replace @python@ ${armpy}/bin/python                  \
      --replace @rippermain@ ${arm-src}/arm/ripper/main.py    \
      --replace @lsdvd@ ${pkgs.lsdvd}/bin/lsdvd               \
      --replace @at@ ${pkgs.at}/bin/at
    chmod +x $out
  '';

  default_config = pkgs.runCommandLocal "arm.yaml" {} ''
    substitute ${./arm.yaml} $out                                   \
      --replace @arm_path@ ${raw_arm_src}                           \
      --replace @abcde_config@ ${./abcde.conf}                      \
      --replace @raw_path@ ${cfg.rawPath}                           \
      --replace @transcode_path@ ${cfg.transcodePath}               \
      --replace @completed_path@ ${cfg.completedPath}               \
      --replace @log_path@ ${cfg.logPath}                           \
      --replace @db_file@ ${cfg.dbFile}                             \
      --replace @web_ip@ ${cfg.webIp}                               \
      --replace @web_port@ ${cfg.webPort}                           \
      --replace @handbrake_cmd@ ${pkgs.handbrake}/bin/HandBrakeCLI  \
      --replace @hb_bd_args@ "${cfg.hbBdArgs}"                      \
      --replace @hb_dvd_args@ "${cfg.hbDvdArgs}"
  '';

  #arm-ui = pkgs.stdenv.mkDerivation {
  #  TODO: implement running the ui
  #};
in {
  options.phil.arm = {
    enable = mkOption {
      description = "enable the arm (automatic media ripping) module";
      type = types.bool;
      default = false;
    };

    outputDir = mkOption {
      description = "directory for the output files";
      type = types.str;
    };

    configFile = mkOption {
      description = "config file";
      type = types.path;
      default = default_config;
    };

    dbFile = mkOption {
      description = "db file";
      type = types.str;
      default = "/home/arm/arm.db";
    };

    hbBdArgs = mkOption {
      description = "handbrake bluray args";
      type = types.str;
      default = "--subtitle scan -F --subtitle-burned --audio-lang-list eng --all-audio";
    };

    hbDvdArgs = mkOption {
      description = "handbrake DVD args";
      type = types.str;
      default = "--subtitle scan -F";
    };

    rawPath = mkOption {
      description = "path for the raw dumps";
      type = types.str;
    };

    transcodePath = mkOption {
      description = "path for the transcoding";
      type = types.str;
    };

    completedPath = mkOption {
      description = "path for the completed transcodes";
      type = types.str;
    };

    logPath = mkOption {
      description = "path for the logs";
      type = types.str;
    };

    webIp = mkOption {
      description = "ip for the web application";
      type = types.str;
      default = "0.0.0.0";
    };

    webPort = mkOption {
      description = "port for the web application";
      type = types.str;
      default = "9091";
    };
  };

  config = mkIf (cfg.enable) {
    boot.kernelModules = [ "sg" ];

    # TODO: debug the script called by this rule (main arm core) -> bails out
    services.udev.extraRules = ''
      ACTION=="change", SUBSYSTEM=="block", RUN+="${arm-core} %k"
    '';

    environment.systemPackages = with pkgs; [
      #libaacs
      #libbluray

      # blurays/dvds
      makemkv
      handbrake

      # cd
      abcde

      # notification daemons
      notify           # discord / telegram
      matrix-commander # matrix
    ];

    systemd.services.arm-ui = {
      description = "Arm ui service";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = { PYTHONPATH = "${arm-src}/"; };

      serviceConfig = {
        User = "arm";
        Group = "arm";
        Restart = "always";

        ExecStart = "${armpy}/bin/python ${arm-src}/arm/runui.py";
      };
    };

    users.extraUsers.arm = {
      isSystemUser = true;
      group = "arm";
      home = "/home/arm";
      createHome = true;
    };

    users.extraGroups.arm = {};
  };
}

