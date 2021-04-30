{
  pkgs,
  username,
  enable_xorg ? false,
  ...
}: let
  usermod = (import ./default.nix { inherit pkgs username; }).userDetails;
  home_directory = "/home/${username}";
  lib = pkgs.stdenv.lib;

  # to avoid infinite recursion in home.username
  user_name = username;
in rec {
  _module.args.username = username;
  _module.args.background_image = usermod.background_image;
  imports = usermod.imports ++ (if enable_xorg then [ ../modules/kde ] else [ ../modules/sway ]);
  home = rec {
    username = "${user_name}";
    homeDirectory = "${home_directory}";
    stateVersion = "21.03";
    sessionVariables = {
      EDITOR = "nvim";
      PAGER = "${pkgs.page}/bin/page";
      MANPAGER = "${pkgs.page}/bin/page -C -e 'au User PageDisconnect sleep 100m|%y p|enew! |bd! #|pu p|set ft=man'";
      _FASD_DATA = "${xdg.dataHome}/fasd/fasd.data";
      _Z_DATA = "${xdg.dataHome}/fasd/z.data";
      CARGO_HOME = "${xdg.dataHome}/cargo";
      RUSTUP_HOME = "${xdg.dataHome}/rustup";
      _ZO_ECHO = 1;
      XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = 1;
      GTK_USE_PORTAL = 1;
      AWT_TOOLKIT = "MToolkit";
      #LIBVA_DRIVER_NAME = "iHD";
    };
    packages = with pkgs; [
      cacert
      coreutils
      mailcap
      curl
      qt5.qtbase
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

    firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        forceWayland = !enable_xorg;
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

  xdg.configFile."newsboat/config".source = ./config/newsboat/config;
}
