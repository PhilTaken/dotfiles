{ self
, inputs
, ...}: let
  inherit (inputs.nixpkgs) lib;

  util = import ../../lib { inherit inputs; };
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
      };
    in
    {
      nixos = {
        userConfig = defaultConfig // {
          wms.hyprland.enable = true;
          #wms.sway.enable = true;
          #wms.bars.waybar.enable = true;

          wms.bars.eww.enable = true;
          #wms.bars.eww.autostart = false;
        };

        extraPackages = pkgs: with pkgs; [
          gnome.adwaita-icon-theme
        ];
      };

      maelstroem = {
        userConfig = defaultConfig // {
          work.enable = true;

          # de/wm config
          wms.hyprland.enable = true;
          #wms.i3.enable = true;

          des.gnome.enable = true;

          wms.bars.eww.enable = true;
          #wms.bars.eww.enableWayland = false;

          #wms.hyprland.enable = true;
          #wms.bars.waybar.enable = true;
        };

        extraPackages = pkgs: with pkgs; [
          # e-guitar stuff
          guitarix
          qjackctl
          jack2

          # tiny media manager
          (nur.repos.shados.tmm.overrideAttrs (old: rec {
            version = "4.3.4";
            src = builtins.fetchurl {
              url = "https://release.tinymediamanager.org/v4/dist/tmm_${version}_linux-amd64.tar.gz";
              sha256 = "sha256:1aj97m186lagaqqvcs2s7hmgk638l5mb98ril4gwgpjqaqj8s57n";
            };
          }))

          # typey-typey
          plover.dev
        ];
      };

      jaid = {
        userConfig = {
          shells.zsh.enable = true;
          des.gnome.enable = true;
          firefox.wayland = false;
        };

        extraPackages = pkgs: [ ];
      };
    };
in {
  flake = {
    nixosConfigurations = {
      # usb stick iso
      x86-iso = util.iso.mkIso {
        inherit (inputs) nixpkgs;
        hostName = "isoInstall";
        system = "x86_64-linux";
      };

      # desktop @ home
      gamma =
        let
          # screw nvidia
          mkHMUsers = users: lib.listToAttrs (map (user: {
            name = user;
            value = lib.recursiveUpdate hmUsers.${user} {
              userConfig.wms.hyprland.terminal = "alacritty";
              userConfig.wms.bars.eww.main_monitor = 0;
            };
          }) users);
        in
        util.host.mkWorkstation rec {
          users = [ "maelstroem" "jaid" ];
          hmUsers = mkHMUsers users;
          systemConfig = {
            server.services.openssh.enable = true;

            core.hostName = "gamma";
            core.enableBluetooth = true;

            nvidia.enable = true;

            video = {
              driver = "nvidia";
              managers = [ "gnome" ];
            };
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
        users = [ "maelstroem" ];
        hmUsers = mkHMUsers users;
        systemConfig = {
          server.services.openssh.enable = true;
          core.hostName = "epsilon";

          laptop.enable = true;
          laptop.wirelessInterfaces = [ "wlp3s0" ];
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

  perSystem = { system,  ... }: {
    #homeConfigurations = lib.mapAttrs (util.user.mkHMUser (util.pkgsFor system)) hmUsers;
    checks = (builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib).${system};

    packages = {
      x86-iso = self.nixosConfigurations.x86-iso.config.system.build.isoImage;
    };
  };
}
