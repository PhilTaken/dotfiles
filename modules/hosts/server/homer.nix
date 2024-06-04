# TODO: https://github.com/mrpbennett/catppucin-homer
{
  pkgs,
  config,
  lib,
  flake,
  ...
}: let
  inherit (lib) mkOption types mkIf mkEnableOption mapAttrsToList;

  cfg = config.phil.server.services.homer;
  net = config.phil.network;
  yaml = pkgs.formats.yaml {};

  homerConfig = let
    settingsForVisible = apps: map (el: el.settings) (builtins.attrValues (lib.filterAttrs (_: v: v.show) apps));
    mkItems = apps: map (lib.filterAttrs (_: v: v != null)) (settingsForVisible apps);
    getAppsFor = system: flake.nixosConfigurations.${system}.config.phil.server.services.homer.apps;
    mkLinks = mapAttrsToList (name: value:
      value
      // {
        inherit name;
        target = "_blank";
      });
  in
    yaml.generate "config.yml" {
      title = "Dashboard";
      subtitle = "Homer";
      header = true;
      connectivityCheck = true;
      defaults.layout = "list";

      links = mkLinks {
        "dotfiles" = {
          icon = "fas fa-code-branch";
          url = "https://gitea.${net.tld}/phil/dotfiles";
        };
      };

      services = [
        {
          name = "Selfhosted Services";
          icon = "fas fa-fire";
          items = builtins.concatMap mkItems (map getAppsFor net.nodes);
        }
        {
          name = "Nix resources";
          icon = "fas fa-snowflake-o";
          items = mkLinks {
            "Nixpkgs" = {
              url = "https://github.com/nixos/nixpkgs";
              subtitle = "the world!";
              icon = "fas fa-code";
              tag = "repo";
              keywords = "nix github nixpkgs";
            };
            "Nixpkgs Issues" = {
              url = "https://github.com/nixos/nixpkgs/issues";
              subtitle = "the problems!";
              icon = "fas fa-code";
              tag = "repo";
              keywords = "nix github nixpkgs issues";
            };
            "Noogle" = {
              url = "https://noogle.dev";
              subtitle = "Library Function Search";
              icon = "fas fa-book";
              tag = "webapp";
              keywords = "nix search library";
            };
            "Nix builtin + lib functions" = {
              url = "https://teu5us.github.io/nix-lib.html#nix-builtin-functions";
              subtitle = "Library Function Search";
              icon = "fas fa-book";
              tag = "webapp";
              keywords = "nix search library";
            };
            "Language Toolkit Reference" = {
              url = "https://ryantm.github.io/nixpkgs/";
              subtitle = "Toolkit References";
              icon = "fas fa-book";
              tag = "webapp";
              keywords = "nix search library reference";
            };
          };
        }
      ];
    };

  # https://github.com/nix-community/nur-combined/blob/master/repos/dukzcry/pkgs/homer.nix
  homer = pkgs.stdenv.mkDerivation rec {
    pname = "homer";
    version = "22.11.2";

    src = pkgs.fetchurl {
      urls = ["https://github.com/bastienwirtz/${pname}/releases/download/v${version}/${pname}.zip"];
      sha256 = "sha256-rOaFjRSg85HDtYD/WJp4vnzBXdDOTazXtNHblMyqC6M=";
    };

    nativeBuildInputs = [pkgs.unzip];
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
      default = {};
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = let
          mkStrOpt = default:
            if default == ""
            then
              mkOption {
                type = types.nullOr types.str;
                default = null;
              }
            else
              mkOption {
                type = types.str;
                inherit default;
              };
        in {
          settings = mkOption {
            type = types.submodule ({...}: {
              options = {
                name = mkOption {
                  type = types.str;
                  default = name;
                };
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
      root = "${homer}";
    };
  };
}
