{
  pkgs,
  username,
  ...
}: let
  usermod = (import ./default.nix { inherit pkgs; }).userDetails;
  home_directory = "/home/${username}";
  lib = pkgs.stdenv.lib;
in rec {
  _module.args.username = username;
  _module.args.background_image = usermod.background_image;
  imports = usermod.imports;
  home = {
    username = "${username}";
    homeDirectory = "${home_directory}";
    stateVersion = "21.03";
    sessionVariables = usermod.sessionVars;
    packages = with pkgs; [
      cacert
      coreutils
      mailcap
      curl
      qt5.qtbase

      # fonts
      iosevka-bin
      weather-icons
      (nerdfonts.override { fonts = [ usermod.font ]; })
      hicolor-icon-theme
    ] ++ usermod.extraPackages;
  };

  programs = {
    home-manager.enable = true;
    gpg = {
      enable = true;
      settings.default-key = usermod.gpgKey;
    };

    # TODO conditional if using wayland or not (most likely)
    firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        forceWayland = true;
        extraPolicies = {
          ExtensionSettings = {};
        };
      };
    };

    #texlive.enable = true;
    zathura.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ usermod.sshKey ];
  };

  xdg = {
    enable = true;
    configHome = "${home_directory}/.config";
    dataHome = "${home_directory}/.local/share";
    cacheHome = "${home_directory}/.cache";
  };

  systemd.user.services.snow-agent = {
    Unit = {
      Description = "Service for the snow agent software";
      After = "network.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.snow-agent}/opt/snow/snowagent -log-dir /tmp -w /tmp test";
      KillMode = "process";
    };

    Install = { WantedBy = [ "multi-user.target"]; };
  };

  # TODO write function that adds all the files in config to xdg automatically
  xdg.configFile."newsboat/config".source = ./config/newsboat/config;
}
