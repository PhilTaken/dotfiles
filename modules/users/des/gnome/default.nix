{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.des.gnome;
  flameshot-gui = pkgs.writeShellScriptBin "flameshot-gui" "${pkgs.flameshot}/bin/flameshot gui";
in {
  options.phil.des.gnome = {
    enable = mkEnableOption "gnome";
  };

  config = mkIf cfg.enable {
    services.flameshot.enable = true;

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };

    home.packages = with pkgs; [
      # chrome-gnome-shell
      # gnome3 apps
      eog # image viewer
      evince # pdf reader

      # desktop look & feel
      # gnome-tweaks
    ];

    programs.gnome-shell.enable = true;
    programs.gnome-shell.extensions = with pkgs; (map (package: {inherit package;}) [
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
      gnomeExtensions.pip-on-top
    ]);

    dconf.settings = {
      # Disables the default screenshot interface
      "org/gnome/shell/keybindings".show-screenshot-ui = [];

      # Sets the new keybindings
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
      };

      # Defines the new shortcut
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Ctrl><Shift>P";
        command = "${flameshot-gui}/bin/flameshot-gui";
        name = "Flameshot";
      };
    };
  };
}
