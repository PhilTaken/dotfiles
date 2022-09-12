_:
final: prev: {
  gopass-rofi = prev.writeShellScriptBin "gopass-rofi" ''
    gopass list --flat |
      rofi -dmenu -matching fuzzy -i -short -sorting-method fzf |
      xargs --no-run-if-empty gopass show -c
  '';
}
