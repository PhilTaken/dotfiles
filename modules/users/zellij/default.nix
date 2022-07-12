{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.zellij;
in
rec {
  options.phil.zellij = {
    enable = mkEnableOption "zellij";
    defaultShell = mkOption {
      type = types.enum [ "fish" "zsh" ];
      default = "zsh";
    };
  };

  config = mkIf (cfg.enable) {
    programs.zellij =
      let
        left = "y";
        down = "n";
        up = "e";
        right = "o";

        defaultBinds = [
          { action = [{ inherit NewPane; }]; key = [{ Alt = "n"; }]; }
          { action = [ "Quit" ]; key = [{ Ctrl = "q"; }]; }
        ];

        focusBinds = [
          { action = [{MoveFocusOrTab = "Left";}]; key = [ {Alt = left;} {Alt = "Left";}]; }  # The {Alt = "Left";} etc. variants are temporary hacks and will be removed in the future - please do not rely on them!
          { action = [{MoveFocusOrTab = "Right";}]; key = [ {Alt = right;} {Alt = "Right";}]; }
          { action = [{MoveFocus = "Down";}]; key = [ {Alt = down;} {Alt = "Down";}]; }
          { action = [{MoveFocus = "Up";}]; key = [ {Alt = up;} {Alt = "Up";}]; }
        ];

        resizeBinds = [
          { action = [{Resize = "Increase";}]; key = [ {Alt = "=";}]; }
          { action = [{Resize = "Increase";}]; key = [ {Alt = "+";}]; }
          { action = [{Resize = "Decrease";}]; key = [ {Alt = "-";}]; }
        ];
      in
      {
        enable = true;
        settings = {
          default-shell = "${pkgs.${cfg.defaultShell}}/bin/${cfg.defaultShell}";
          theme = "nord";
          plugins = [
            { path = "tab-bar"; tag = "tab-bar"; }
            { path = "status-bar"; tag = "status-bar"; }
            { path = "strider"; tag = "strider"; }
            { path = "compact-bar"; tag = "compact-bar"; }
          ];
          keybinds = {
            unbind = true;
            normal = [
              { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
              { action = [{ SwitchToMode = "Pane"; }]; key = [{ Ctrl = "p"; }]; }
              { action = [{ SwitchToMode = "Resize"; }]; key = [{ Ctrl = "n"; }]; }
              { action = [{ SwitchToMode = "Tab"; }]; key = [{ Ctrl = "t"; }]; }
              { action = [{ SwitchToMode = "Scroll"; }]; key = [{ Ctrl = "s"; }]; }
              { action = [{ SwitchToMode = "Session"; }]; key = [{ Ctrl = "o"; }]; }
              { action = [{ SwitchToMode = "Move"; }]; key = [{ Ctrl = "h"; }]; }
              { action = [{ SwitchToMode = "Tmux"; }]; key = [{ Ctrl = "a"; }]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            locked = [{ action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "g"; }]; }];

            resize = [
              { action = [{SwitchToMode = "Locked";}]; key = [{Ctrl = "g";}]; }
              { action = [{SwitchToMode = "Move";}]; key = [{Ctrl = "h";}]; }
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "n";} "Esc"]; }
              { action = [{SwitchToMode = "Pane";}]; key = [{Ctrl = "p";}]; }
              { action = [{SwitchToMode = "Scroll";}]; key = [{Ctrl = "s";}]; }
              { action = [{SwitchToMode = "Session";}]; key = [{Ctrl = "o";}]; }
              { action = [{SwitchToMode = "Tab";}]; key = [{Ctrl = "t";}]; }
              { action = [{SwitchToMode = "Tmux";}]; key = [{Ctrl = "a";}]; }

              { action = [{Resize = "Increase";}]; key = [{Char = "=";}]; }
              { action = [{Resize = "Increase";}]; key = [ {Char = "+";}]; }
              { action = [{Resize = "Decrease";}]; key = [{Char = "-";}]; }
              { action = [{Resize = "Left";}]; key = [{Char = left;} "Left"]; }
              { action = [{Resize = "Down";}]; key = [{Char = down;} "Down"]; }
              { action = [{Resize = "Up";}]; key = [{Char = up;} "Up" ]; }
              { action = [{Resize = "Right";}]; key = [{Char = right;} "Right"]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            pane = [
              { action = [{SwitchToMode = "Locked";}]; key = [{Ctrl = "g";}]; }
              { action = [{SwitchToMode = "Move";}]; key = [{Ctrl = "h";}]; }
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "p";} "Esc"]; }
              { action = [{SwitchToMode = "RenamePane";} {PaneNameInput = [0];}]; key = [{Char = "c";}]; }
              { action = [{SwitchToMode = "Resize";}]; key = [{Ctrl = "n";}]; }
              { action = [{SwitchToMode = "Scroll";}]; key = [{Ctrl = "s";}]; }
              { action = [{SwitchToMode = "Session";}]; key = [{Ctrl = "o";}]; }
              { action = [{SwitchToMode = "Tab";}]; key = [{Ctrl = "t";}]; }
              { action = [{SwitchToMode = "Tmux";}]; key = [{Ctrl = "a";}]; }

              { action = ["SwitchFocus"]; key = [{Char = "p";}]; }
              { action = [{MoveFocus = "Down";}]; key = [ {Char = down;} "Down"]; }
              { action = [{MoveFocus = "Up";}]; key = [ {Char = up;} "Up"]; }
              { action = [{MoveFocus = "Left";}]; key = [ {Char = left;} "Left"]; }
              { action = [{MoveFocus = "Right";}]; key = [ {Char = right;} "Right"]; }

              { action = [{NewPane = "Left";} {SwitchToMode = "Normal";}]; key = [{Char = "n";}]; }
              { action = [{NewPane = "Down";} {SwitchToMode = "Normal";}]; key = [{Char = "d";}]; }
              { action = [{NewPane = "Right";} {SwitchToMode = "Normal";}]; key = [{Char = "r";}]; }
              { action = ["CloseFocus" {SwitchToMode = "Normal";}]; key = [{Char = "x";}]; }
              { action = ["ToggleFocusFullscreen" {SwitchToMode = "Normal";}]; key = [{Char = "f";}]; }
              { action = ["TogglePaneFrames" {SwitchToMode = "Normal";}]; key = [{Char = "z";}]; }
              { action = ["ToggleFloatingPanes" {SwitchToMode = "Normal";}]; key = [{Char = "w";}]; }
              { action = ["TogglePaneEmbedOrFloating" {SwitchToMode = "Normal";}]; key = [{Char = "e";}]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            move = [
              { action = [{SwitchToMode = "Locked";}]; key = [{Ctrl = "g";}]; }
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "h";} "Esc"]; }
              { action = [{SwitchToMode = "Pane";}]; key = [{Ctrl = "p";}]; }
              { action = [{SwitchToMode = "Resize";}]; key = [{Ctrl = "n";}]; }
              { action = [{SwitchToMode = "Scroll";}]; key = [{Ctrl = "s";}]; }
              { action = [{SwitchToMode = "Session";}]; key = [{Ctrl = "o";}]; }
              { action = [{SwitchToMode = "Tab";}]; key = [{Ctrl = "t";}]; }

              { action = [{MovePane = "Left";}]; key = [{Char = "n";} ]; }
              { action = [{MovePane = "Left";}]; key = [{Char = left;} "Left"]; }
              { action = [{MovePane = "Down";}]; key = [{Char = down;} "Down"]; }
              { action = [{MovePane = "Up";}]; key = [{Char = up;} "Up" ]; }
              { action = [{MovePane = "Right";}]; key = [{Char = right;} "Right"]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            tab = [
              { action = [{SwitchToMode = "Locked";}]; key = [{Ctrl = "g";}]; }
              { action = [{SwitchToMode = "Move";}]; key = [{Ctrl = "h";}]; }
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "t";} "Esc"]; }
              { action = [{SwitchToMode = "Pane";}]; key = [{Ctrl = "p";}]; }
              { action = [{SwitchToMode = "Resize";}]; key = [{Ctrl = "n";}]; }
              { action = [{SwitchToMode = "Scroll";}]; key = [{Ctrl = "s";}]; }
              { action = [{SwitchToMode = "Session";}]; key = [{Ctrl = "o";}]; }
              { action = [{SwitchToMode = "Tmux";}]; key = [{Ctrl = "a";}]; }

              { action = ["GoToPreviousTab"]; key = [ {Char = left;} "Left" "Up" {Char = up;}]; }
              { action = ["GoToNextTab"]; key = [ {Char = right;} "Right" "Down" {Char = down;}]; }
              { action = ["CloseTab" {SwitchToMode = "Normal";}]; key = [ {Char = "x";}]; }
              { action = ["ToggleActiveSyncTab" {SwitchToMode = "Normal";}]; key = [{Char = "s";}]; }

              { action = [{GoToTab = 1;} {SwitchToMode = "Normal";}]; key = [ {Char = "1";}]; }
              { action = [{GoToTab = 2;} {SwitchToMode = "Normal";}]; key = [ {Char = "2";}]; }
              { action = [{GoToTab = 3;} {SwitchToMode = "Normal";}]; key = [ {Char = "3";}]; }
              { action = [{GoToTab = 4;} {SwitchToMode = "Normal";}]; key = [ {Char = "4";}]; }
              { action = [{GoToTab = 5;} {SwitchToMode = "Normal";}]; key = [ {Char = "5";}]; }
              { action = [{GoToTab = 6;} {SwitchToMode = "Normal";}]; key = [ {Char = "6";}]; }
              { action = [{GoToTab = 7;} {SwitchToMode = "Normal";}]; key = [ {Char = "7";}]; }
              { action = [{GoToTab = 8;} {SwitchToMode = "Normal";}]; key = [ {Char = "8";}]; }
              { action = [{GoToTab = 9;} {SwitchToMode = "Normal";}]; key = [ {Char = "9";}]; }

              { action = [{SwitchToMode = "RenameTab";} {TabNameInput = [0];}]; key = [{Char = "r";}]; }
              { action = [{NewTab = {};} {SwitchToMode = "Normal";}]; key = [ {Char = "n";}]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            scroll = [
              { action = [{SwitchToMode = "Locked";}]; key = [{Ctrl = "g";}]; }
              { action = [{SwitchToMode = "Move";}]; key = [{Ctrl = "h";}]; }
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "s";} "Esc"]; }
              { action = [{SwitchToMode = "Pane";}]; key = [{Ctrl = "p";}]; }
              { action = [{SwitchToMode = "Resize";}]; key = [{Ctrl = "n";}]; }
              { action = [{SwitchToMode = "Session";}]; key = [{Ctrl = "o";}]; }
              { action = [{SwitchToMode = "Tab";}]; key = [{Ctrl = "t";}]; }
              { action = [{SwitchToMode = "Tmux";}]; key = [{Ctrl = "a";}]; }

              { action = ["EditScrollback" {SwitchToMode = "Normal";}]; key = [{Char = "e";}]; }
              { action = ["ScrollToBottom" {SwitchToMode = "Normal";}]; key = [{Ctrl = "c";}]; }
              { action = ["ScrollDown"]; key = [{Char = down;} "Down"]; }
              { action = ["ScrollUp"]; key = [{Char = up;} "Up"]; }
              { action = ["PageScrollDown"]; key = [{Ctrl = "f";} "PageDown" "Right" {Char = right;}]; }
              { action = ["PageScrollUp"]; key = [{Ctrl = "b";}  "PageUp" "Left" {Char = left;}]; }
              { action = ["HalfPageScrollDown"]; key = [{Char = "d";}]; }
              { action = ["HalfPageScrollUp"]; key = [{Char = "u";}]; }
            ] ++ defaultBinds;

            renametab = [
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "c";} "Esc"]; }
              { action = [{TabNameInput = [27];} {SwitchToMode = "Tab";}]; key = ["Esc"]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            renamepane = [
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "c";} "Esc"]; }
              { action = [{PaneNameInput = [27];}  {SwitchToMode = "Pane";}]; key = ["Esc"]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            session = [
              { action = [{SwitchToMode = "Locked";}]; key = [{Ctrl = "g";}]; }
              { action = [{SwitchToMode = "Move";}]; key = [{Ctrl = "h";}]; }
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "o";} "Esc"]; }
              { action = [{SwitchToMode = "Pane";}]; key = [{Ctrl = "p";}]; }
              { action = [{SwitchToMode = "Resize";}]; key = [{Ctrl = "n";}]; }
              { action = [{SwitchToMode = "Scroll";}]; key = [{Ctrl = "s";}]; }
              { action = [{SwitchToMode = "Tab";}]; key = [{Ctrl = "t";}]; }
              { action = [{SwitchToMode = "Tmux";}]; key = [{Ctrl = "a";}]; }

              { action = ["Detach"]; key = [{Char = "d";}]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            tmux = [
              { action = [{SwitchToMode = "Locked";}]; key = [{Ctrl = "g";}]; }
              { action = [{SwitchToMode = "Move";}]; key = [{Ctrl = "h";}]; }
              { action = [{SwitchToMode = "Normal";}]; key = [{Ctrl = "o";} "Esc"]; }
              { action = [{SwitchToMode = "Pane";}]; key = [{Ctrl = "p";}]; }
              { action = [{SwitchToMode = "RenameTab";} {TabNameInput = [0];}]; key = [{Char = ",";}]; }
              { action = [{SwitchToMode = "Resize";}]; key = [{Ctrl = "n";}]; }
              { action = [{SwitchToMode = "Scroll";}]; key = [{Ctrl = "s";}]; }
              { action = [{SwitchToMode = "Tab";}]; key = [{Ctrl = "t";}]; }

              { action = [{NewPane = "Down";} {SwitchToMode = "Normal";}]; key = [{Char = "-";}]; }
              { action = [{NewPane = "Right";} {SwitchToMode = "Normal";}]; key = [{Char = "|";}]; }
              { action = [{NewTab = {};} {SwitchToMode = "Normal";}]; key = [ {Char = "c";}]; }
              { action = [{Write = [2];} {SwitchToMode = "Normal";}]; key = [{Ctrl = "a";}]; }

              { action = ["ToggleFocusFullscreen" {SwitchToMode = "Normal";}]; key = [{Char = "z";}]; }
              { action = ["GoToPreviousTab" {SwitchToMode = "Normal";}]; key = [ {Char = "p";}]; }
              { action = ["GoToNextTab" {SwitchToMode = "Normal";}]; key = [ {Char = "n";}]; }

              { action = [{MoveFocus = "Left";} {SwitchToMode = "Normal";}]; key = ["Left" {Char = left; }]; }
              { action = [{MoveFocus = "Right";} {SwitchToMode = "Normal";}]; key = ["Right" {Char = right;}]; }
              { action = [{MoveFocus = "Down";} {SwitchToMode = "Normal";}]; key = ["Down" {Char = down;}]; }
              { action = [{MoveFocus = "Up";} {SwitchToMode = "Normal";}]; key = ["Up" {Char = up;}]; }

              { action = ["FocusNextPane"]; key = [ {Char = "o";}]; }
              { action = ["Detach"]; key = [{Char = "d";}]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;
          };
        };
      };
  };
}
