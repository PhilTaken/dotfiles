{ pkgs, ...}:
let
  shellPackages = with pkgs; [
    fd
    nixpkgs-fmt
    sops
    age

    sops-import-keys-hook
    ssh-to-age
  ];
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
          name = "switch";
          help = "Switch to a NixOS Configuration (local)";
          command = ''
          if [[ -z "$@" || "$1" == "help" ]]; then
          echo -e "Available configs:"
          nix flake show 2>/dev/null | grep nixosConfigurations -A 200 | tail +2 | sed 's/:.*//'
          else
          sudo nixos-rebuild --flake ".#$1" switch
          fi
          '';
          category = "system";
        }

        {
          name = "uswitch";
          help = "Build + switch to a user configuration with home-manager";
          command = ''
          if [[ -z "$@" || "$1" == "help" ]]; then
          echo -e "Available configs:"
          echo -e "\tnixos"
          echo -e "\tmaelstroem"
          else
          nix build ".#homeManagerConfigurations.$1.activationPackage" && result/activate
          fi
          '';
          category = "system";
        }
      ];
    };
  }
