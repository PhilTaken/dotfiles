{
  self,
  inputs,
  ...
}: let
  mkSystemScript = commands: ''
    if [[ -z "$@" || "$1" == "help" ]]; then
      eval configurations=$(nix eval --raw --impure --expr '(builtins.concatStringsSep " " (["("] ++ (builtins.map builtins.toJSON (builtins.attrNames (builtins.getFlake "'$PWD'").outputs.nixosConfigurations)) ++ [")"]))')
      eval darwin_configurations=$(nix eval --raw --impure --expr '(builtins.concatStringsSep " " (["("] ++ (builtins.map builtins.toJSON (builtins.attrNames (builtins.getFlake "'$PWD'").outputs.darwinConfigurations)) ++ [")"]))')

      echo -e "Available configs:"
      echo -e "- nixos:"
      for i in ''${configurations[@]}; do
        echo -e "  - .#$i"
      done
      echo -e "- darwin:"
      for i in ''${darwin_configurations[@]}; do
        echo -e "  - .#$i"
      done
    else
      ${commands}
    fi
  '';

  net = import ../../network.nix {};
in {
  perSystem = {
    system,
    config,
    ...
  }: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.devshell.overlays.default
        inputs.sops-nix-src.overlays.default
        inputs.deploy-rs.overlay
        self.overlays.default
      ];
    };
    inherit (pkgs) lib;

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

      nix-prefetch-git
      npins

      racket-langserver
    ];
  in {
    devShells.legacy = pkgs.mkShell {
      buildInputs = shellPackages;
    };

    devShells.default = pkgs.devshell.mkShell {
      name = "dotfiles";
      packages = shellPackages;

      devshell.startup = {
        pre-commit.text = config.pre-commit.devShell.shellHook;
      };

      commands = [
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
            if [ $(uname -a | cut -d " " -f 1) == "Darwin" ]; then
              sudo darwin-rebuild --flake ".#$1" build ''${@:2} |& ${pkgs.nix-output-monitor}/bin/nom
            else
              nixos-rebuild --use-remote-sudo --flake ".#$1" build ''${@:2} |& ${pkgs.nix-output-monitor}/bin/nom
            fi
            ${pkgs.nvd}/bin/nvd diff /run/current-system result
          '';
          category = "system";
        }

        {
          name = "cswitch";
          help = "Switch to a NixOS Configuration (local)";
          command = mkSystemScript ''
            if [ $(uname -a | cut -d " " -f 1) == "Darwin" ]; then
              sudo darwin-rebuild --flake ".#$1" switch ''${@:2} |& ${pkgs.nix-output-monitor}/bin/nom
            else
              nixos-rebuild --use-remote-sudo --flake ".#$1" switch ''${@:2} |& ${pkgs.nix-output-monitor}/bin/nom
            fi
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
          help = "sign all configurations";
          command = lib.concatStrings (lib.mapAttrsToList
            (name: ip: let
              cidr = builtins.elemAt (lib.splitString "/" net.networks.milkyway.gateway) 1;
            in ''
              ${pkgs.nebula}/bin/nebula-cert sign \
                -ca-crt /run/secrets/ca \
                -ca-key /run/secrets/key \
                -name ${name} -ip ${ip}/${cidr}
            '')
            (lib.filterAttrs (n: _: ! builtins.elem n ["interfaceName" "gateway"]) net.networks.milkyway));
        }

        {
          name = "goback";
          help = "revert to previous config";
          command = ''
            if [ $(uname -a | cut -d " " -f 1) == "Darwin" ]; then
              sudo darwin-rebuild switch --rollback --flake .
            else
              sudo nixos-rebuild switch --rollback --flake .
            fi
          '';
          category = "system";
        }
      ];
    };
  };
}
