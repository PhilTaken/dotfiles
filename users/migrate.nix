{
  # MAELSTROEM

  font = "SourceCodePro";
  pamfile = ../secret/ykchal/maelstroem-14321676;
  background_image = ./wallpaper/river.jpg;
  extraPackages = with pkgs; [
    neuron-notes
    youtube-dl
    anki
    audacity
    chromium
    citra
    digikam
    discord
    element-desktop
    gimp
    libreoffice
    obs-studio
    obsidian
    signal-desktop
    tdesktop
    zoom-us
    cachix
    texlive.combined.scheme-medium
    vpnc
    multimc
    openttd
    keepassxc
  ];

  # NIXOS


  pamfile = ../secret/ykchal/nixos-14321676;
  background_image = ./wallpaper/city-night.png;
  font = "SourceCodePro";

  extraPackages = with pkgs; [
    cmake
    tokei
    hyperfine
    youtube-dl
    jq
    tree
    wget
    discord
    gimp
    tdesktop
    element-desktop
    anki
    texlive.combined.scheme-medium
    cachix
    magic-wormhole
    gping
    goneovim
    tightvnc
    obsidian
    fortran-package-manager
    keepassxc
    zoom-us
  ];
}
