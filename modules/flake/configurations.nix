{ self
, inputs
, ...
}:
let
  inherit (inputs.nixpkgs) lib;

  util = import ../../lib { inherit inputs self; };
  net = import ../../network.nix { };

  mkHMUsers = users: lib.listToAttrs (map (user: lib.nameValuePair user hmUsers.${user}) users);

  hmUsers =
    let
      defaultConfig = {
        shells.fish.enable = true;
        tmux = {
          enable = true;
          defaultShell = "fish";
        };
        zellij.enable = true;
        music.enableMpris = true;
      };
    in
    {
      nixos = {
        userConfig = defaultConfig // {
          work.enable = true;

          # de/wm config
          wms.hyprland.enable = true;
          #wms.i3.enable = true;

          terminals.multiplexer = "zellij";
          editors.emacs.enable = false;

          wms.bars.eww.enable = true;
          #wms.bars.eww.enableWayland = false;

          #wms.hyprland.enable = true;
          #wms.bars.waybar.enable = true;
        };
      };

      maelstroem = {
        userConfig = defaultConfig // {
          work.enable = true;

          # de/wm config
          wms.hyprland.enable = true;
          #wms.i3.enable = true;

          des.gnome.enable = true;

          terminals.multiplexer = "zellij";

          wms.bars.eww.enable = true;

          #wms.bars.eww.enableWayland = false;

          #wms.hyprland.enable = true;
          #wms.bars.waybar.enable = true;
        };

        extraPackages = pkgs: [ ];
      };

      jaid = {
        userConfig = {
          shells.zsh.enable = true;
          des.gnome.enable = true;
          browsers.firefox.wayland = false;
        };

        extraPackages = pkgs: [ ];
      };
    };
in
{
  flake = {
    nixosConfigurations = {
      # usb stick iso
      x86-iso = util.iso.mkIso {
        inherit (inputs) nixpkgs;
        hostName = "isoInstall";
        system = "x86_64-linux";
      };

      x86-iso2 = util.host.mkHost rec {
        users = [ "nixos" ];
        hmUsers = mkHMUsers users;

        extraHostModules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          ({...}: {
            # WIP: decrypt secrets with yubikey
            #sops.gnupg = {
              #home = "/run/gpghome";
              #sshKeyPaths = [];
            #};
          })
        ];

        systemConfig = {
          server.services.openssh.enable = true;
          dns.nameserver = null;
          wireguard.enable = false;
          core.hostName = "iso";
        };

        hardware-config = {};
      };

      # desktop @ home
      gamma =
        let
          # screw nvidia
          mkHMUsers = users: lib.listToAttrs (map
            (user: {
              name = user;
              value = lib.recursiveUpdate hmUsers.${user} {
                userConfig.wms.hyprland.terminal = "alacritty";
              };
            })
            users);
        in
        util.host.mkWorkstation rec {
          users = [ "maelstroem" "nixos" "jaid" ];
          hmUsers = mkHMUsers users;
          systemConfig = {
            server.services.openssh.enable = true;

            core.hostName = "gamma";
            core.enableBluetooth = true;

            desktop.enable = true;
            development.enable = true;
            nvidia.enable = true;
            video.managers = [ "gnome" ];
          };

          extraHostModules = with inputs.nixos-hardware.nixosModules; [
            common-pc
            common-pc-ssd
            common-cpu-amd
            #common-gpu-nvidia
          ];
        };

      # future laptop config
      epsilon = util.host.mkWorkstation rec {
        users = [ "nixos" ];
        hmUsers = mkHMUsers users;
        systemConfig = {
          server.services.openssh.enable = true;
          core.hostName = "epsilon";

          laptop.enable = true;
          laptop.low_power = true;
        };

        extraHostModules = with inputs.nixos-hardware.nixosModules; [
          common-pc-laptop
          common-pc-laptop-ssd
          common-cpu-intel-cpu-only
          common-cpu-intel-kaby-lake
        ];
      };
    } //
    builtins.mapAttrs
      (servername: services: util.server.mkServer { inherit servername services; })
      net.services;

    # shortcut for building with `nix build`
    systems = builtins.mapAttrs (system: _: self.nixosConfigurations.${system}.config.system.build.toplevel) self.nixosConfigurations;
  };

  perSystem = { system, ... }: {
    #homeConfigurations = lib.mapAttrs (util.user.mkHMUser (util.pkgsFor system)) hmUsers;
    checks = (builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib).${system};

    # requires ifd :/
    packages = (lib.mapAttrs' (n: v: {
      name = "${n}-iso";
      value = v.config.system.build.isoImage;
    }) (lib.filterAttrs (n: v: v.config.system.build ? isoImage) self.nixosConfigurations))
    // (lib.mapAttrs' (n: v: {
      name = "${n}-disko-setup";
      value = v.config.system.build.disko;
    }) (lib.filterAttrs (n: v: v.config.system.build ? disko) self.nixosConfigurations));
  };
}
