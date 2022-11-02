{ pkgs, lib, ... }:
let
  shellPackages = with pkgs; [
    fd
    nixpkgs-fmt
    sops
    age

    sops-import-keys-hook
    ssh-to-age
    nvd
    statix

    jq
    cachix
  ];

  mkSystemScript = commands: ''
    if [[ -z "$@" || "$1" == "help" ]]; then
      eval configurations=$(nix eval --raw --impure --expr '(builtins.concatStringsSep " " (["("] ++ (builtins.map builtins.toJSON (builtins.attrNames (builtins.getFlake "'$PWD'").outputs.nixosConfigurations)) ++ [")"]))')

      echo -e "Available configs:"
      for i in ''${configurations[@]}; do
        echo -e "  - $i"
      done
    else
      ${commands}
    fi
  '';

  net = import ../network.nix { };
in
{
  legacyShell = pkgs.mkShell {
    buildInputs = shellPackages;
  };

  devShell = pkgs.devshell.mkShell {
    name = "dotfiles";
    packages = shellPackages;

    commands =
      [
        {
          name = "fmt";
          help = "Autoformat Nix files";
          command = "nixpkgs-fmt \${@} $PRJ_ROOT";
          category = "dev";
        }

        {
          name = "statix";
          help = "Static analysis for nix files";
          package = pkgs.statix;
          category = "dev";
        }

        {
          name = "evalnix";
          help = "Check Nix parsing";
          command = "fd --extension nix --exec nix-instantiate --parse --quiet {} >/dev/null";
          category = "dev";
        }

        {
          name = "sops";
          help = "Create/edit a secret file";
          package = pkgs.sops;
          category = "dev";
        }

        {
          name = "deploy";
          help = "deploy to remote hosts";
          package = pkgs.deploy-rs.deploy-rs;
          category = "remote";
        }

        {
          name = "update";
          help = "Update + Commit the Lock File";
          command = "nix flake update --commit-lock-file";
          category = "system";
        }

        {
          name = "sign";
          help = "sign nebula certificates - wrapper around nebula-sign (needs sudo)";
          category = "dev";
          command = "nebsign";
        }

        {
          name = "cbuild";
          help = "Build and compare a NixOS Configuration (local)";
          command = mkSystemScript ''
            nixos-rebuild --use-remote-sudo --flake ".#$1" build ''${@:2}
            ${pkgs.nvd}/bin/nvd diff /run/current-system result
          '';
          category = "system";
        }

        {
          name = "cswitch";
          help = "Switch to a NixOS Configuration (local)";
          command = mkSystemScript ''
            nixos-rebuild --use-remote-sudo --flake ".#$1" switch ''${@:2}
          '';
          category = "system";
        }

        {
          name = "uswitch";
          help = "Build + switch to a user configuration with home-manager";
          command = ''
            if [[ -z "$@" || "$1" == "help" ]]; then
              eval configurations=$(nix eval --raw --impure --expr '(builtins.concatStringsSep " " (["("] ++ (builtins.map builtins.toJSON (builtins.attrNames (builtins.getFlake "'$PWD'").outputs.homeConfigurations)) ++ [")"]))')
              echo -e "Available configs:"
              for i in ''${configurations[@]}; do
                echo -e "  - $i"
              done
            else
              nix build ".#homeConfigurations.$1.activationPackage" && result/activate
            fi
          '';
          category = "system";
        }

        {
          # TODO: rotate keys with sops, this script just generates new certs
          name = "signall";
          help = "sign all confiurations";
          command = lib.concatStrings (lib.mapAttrsToList
            (name: ip:
              let
                cidr = builtins.elemAt (lib.splitString "/" net.networks.milkyway.gateway) 1;
              in
              ''
                ${pkgs.nebula}/bin/nebula-cert sign \
                  -ca-crt /run/secrets/ca \
                  -ca-key /run/secrets/key \
                  -name ${name} -ip ${ip}/${cidr}
              '')
            (lib.filterAttrs (n: _: ! builtins.elem n [ "interfaceName" "gateway" ]) net.networks.milkyway));
        }

        {
          name = "goback";
          help = "revert to previous config";
          command = ''
            sudo nixos-rebuild switch --rollback --flake .
          '';
          category = "system";
        }
      ];
  };
}
