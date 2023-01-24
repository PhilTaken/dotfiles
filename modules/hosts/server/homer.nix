# TODO:
# - https://github.com/mrpbennett/catppucin-homer
# - also link to services on other nodes

{ pkgs
, config
, inputs
, lib
, net
, ...
}:
let
  inherit (lib) mkOption types mkIf mkEnableOption mapAttrsToList;

  cfg = config.phil.server.services.homer;

  yaml = pkgs.formats.yaml {};

  homerConfig = yaml.generate "config.yml" {
    title = "Dashboard";
    subtitle = "Homer";
    header = true;
    connectivityCheck = true;
    defaults.layout = "list";

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
        items = map
          (lib.filterAttrs (_: v: v != null))
          (map
            (el: el.settings)
            (builtins.attrValues
              (lib.filterAttrs
                (_: v: v.show)
                cfg.apps)));
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

    apps = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = let
          mkStrOpt = default: if default == "" then mkOption { type = types.nullOr types.str; default = null; } else mkOption { type = types.str; inherit default; };
        in {
          settings = mkOption {
            type = types.submodule ({ config, ... }: {
              options = {
                name = mkOption { type = types.str; default = name; };
                subtitle = mkStrOpt "";
                logo = mkStrOpt "";
                icon = mkStrOpt "";
                tag = mkStrOpt "";
                tagstyle = mkStrOpt "";
                keywords = mkStrOpt "";
                url = mkStrOpt "https://${name}.${net.tld}";
                target = mkStrOpt "_blank";
              };
            });

            default = {};
          };

          show = mkEnableOption "show";
        };
      }));

      default = {};
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
