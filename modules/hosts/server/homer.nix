# TODO:
# - https://github.com/mrpbennett/catppucin-homer

{ pkgs
, config
, inputs
, lib
, net
, flake
, ...
}:
let
  inherit (lib) mkOption types mkIf mkEnableOption mapAttrsToList flip;
  inherit (builtins) attrNames elem;

  cfg = config.phil.server.services.homer;

  yaml = pkgs.formats.yaml {};

  homerConfig = let
    settingsFor = apps: map (el: el.settings) (builtins.attrValues (lib.filterAttrs (_: v: v.show) apps));
    filterNull = lib.filterAttrs (_: v: v != null);
    mkItems = apps: map filterNull (settingsFor apps);
    getAppsFor = system: flake.nixosConfigurations.${system}.config.phil.server.services.homer.apps;
  in yaml.generate "config.yml" {
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
      "dotfiles" = {
        icon = "fas fa-code-branch";
        url = "https://gitea.pherzog.xyz/phil/dotfiles";
      };
    };

    services = [
      {
        name = "selfhosted";
        icon = "fas fa-code-branch";
        items = builtins.concatMap mkItems (map getAppsFor net.servers);
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
          mkStrOpt = default: if default == "" then
            mkOption { type = types.nullOr types.str; default = null; }
          else
            mkOption { type = types.str; inherit default; };
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
