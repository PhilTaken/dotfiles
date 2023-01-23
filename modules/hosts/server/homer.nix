{ pkgs
, config
, inputs
, lib
, ...
}:
let
  inherit (lib) mkOption types mkIf mkEnableOption mapAttrsToList;

  cfg = config.phil.server.services.homer;

  net = import ../../../network.nix {};

  yaml = pkgs.formats.yaml {};

  homerConfig = yaml.generate "config.yml" {
    title = "Dashboard";
    subtitle = "Homer";
    header = true;
    connectivityCheck = true;

    links = mapAttrsToList (name: value: value // { inherit name; target = "_blank"; }) {
      "nixpkgs" = {
        icon = "fab fa-github";
        url = "https://github.com/nixos/nixpkgs";
      };
    };

    services = [
      {
        name = "selfhosted";
        icon = "fas fa-code-branch";
        items = map (app: {
          name = app;
          icon = "icon";
          url = "https://${app}.${net.tld}";
          target = "_blank";
        }) (builtins.attrNames config.phil.server.services.unbound.apps);
      }
    ];
  };

  # https://github.com/nix-community/nur-combined/blob/master/repos/dukzcry/pkgs/homer.nix
  homer = pkgs.stdenv.mkDerivation rec {
    pname = "homer";
    version = "22.11.2";

    src = pkgs.fetchurl {
      urls = [ "https://github.com/bastienwirtz/${pname}/releases/download/v${version}/${pname}.zip" ];
      sha256 = "sha256-rOaFjRSg85HDtYD/WJp4vnzBXdDOTazXtNHblMyqC6M=";
    };

    nativeBuildInputs = [ pkgs.unzip ];
    dontInstall = true;
    sourceRoot = ".";
    unpackCmd = "${pkgs.unzip}/bin/unzip -d $out $curSrc";

    buildPhase = ''
      cp ${homerConfig} $out/assets/config.yml
    '';
  };
in {
  options.phil.server.services.homer = {
    enable = mkEnableOption "homer module";

    host = mkOption {
      type = types.str;
      default = "homer";
    };
  };

  config = mkIf cfg.enable {
    phil.server.services.caddy.proxy."${cfg.host}" = {
      proxycfg = ''
        root * ${homer}
        encode gzip
        file_server
      '';
    };
  };
}
