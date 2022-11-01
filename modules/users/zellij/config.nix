{ pkgs
, cfg
, ...
}:

let
  inherit (pkgs) lib;

  # -------------------------

  tabstr = nspaces: string:
    lib.fixedWidthString ((nspaces * 2) + lib.stringLength string) "  " string;

  generate = name: settings: pkgs.writeText name (toZellij { } (settings // { keybinds = mkKeybinds settings.keybinds; }));

  ensureList = v: if builtins.isList v then v else [ v ];
  ensureAttr = v: if builtins.isAttrs v then v else { ${v} = { }; };

  toZellij = { depth ? 0 }@args: v:
    with builtins;
    let
      toplevel = depth == 0;

      concatAttrList = args: lib.concatStrings (lib.intersperse "\n" (map (item: tabstr depth item) args));
      concatList = lib.concatStringsSep " ";

      attrList = v: (lib.attrsets.mapAttrsToList
        (key: value:
          # do not include empty attrs
          if value != { } then "${key} ${toZellij { depth = depth + 1; } value}" else key)
        v);
      attrs = v: (concatAttrList (attrList v));
      list = v: concatList (map (toZellij args) v);
      bool = v: if v then "true" else "false";
    in
    if isAttrs v then
      let
        props = v._properties or { };
        cleanAttrs = builtins.removeAttrs v [ "_properties" ];
        attrsString = attrs cleanAttrs;

        extraArgsString = lib.concatStringsSep " "
          (lib.mapAttrsToList (id: value: "${id}=${toZellij {depth = depth + 1; } value}") props);

        # check for simple attrsets that can be inlined
        hasSimpleKey = v:
          let
            singlekey = builtins.length (builtins.attrNames v) == 1;
            firstval = builtins.head (builtins.attrValues v);
          in
          singlekey && (!isAttrs firstval || firstval == { }) && (!isList firstval || firstval == [ ]);

        inner =
          # no brackets around toplevel attributes
          if toplevel then attrsString
          # to inline simple attribute sets (NOTE: requires semicolon at the end!)
          else if hasSimpleKey cleanAttrs then "{ ${builtins.head (attrList cleanAttrs)}; }"
          else "{\n${attrsString}" + "\n" + (tabstr (depth - 1) "}");
      in
      lib.concatStringsSep " " (lib.optional (extraArgsString != "") extraArgsString ++ [ inner ])

    else if isList v then list v
    else if isInt v || isFloat v then toString v
    else if isBool v then bool v
    else if isString v then toJSON v
    else abort "kdl format: should never happen (value = ${v})";

  mkKeybinds = v: lib.mapAttrs
    (name: value: builtins.listToAttrs (map
      (kb:
        let
          keys = lib.concatStringsSep " " (map (k: "\"${k}\"") (map
            (i:
              let
                key = builtins.head (builtins.attrNames i);
                value = builtins.head (builtins.attrValues i);
              in
              if builtins.isString i then i else "${key} ${value}")
            (ensureList kb.key)));

          raw_action = map ensureAttr (ensureList kb.action);
          action = builtins.listToAttrs (map
            (i:
              let
                key = builtins.head (builtins.attrNames i);
                value = builtins.head (builtins.attrValues i);
              in
              {
                name =
                  if (value == { }) then builtins.toString key
                  else if !builtins.isString value then "${key} ${builtins.toString value}"
                  else "${key} \"${builtins.toString value}\"";
                value = { };
              })
            raw_action);
        in
        lib.nameValuePair "bind ${keys}" action)
      value))
    (builtins.removeAttrs v [ "_properties" ]) // { _properties = v._properties or { }; };

  # -------------------------


  zj_settings =
    let
      left = "y";
      down = "n";
      up = "e";
      right = "o";

      defaultBinds = [
        { action = [{ NewPane = "Left"; }]; key = [{ Alt = "n"; }]; }
        { action = [ "Quit" ]; key = [{ Ctrl = "q"; }]; }
      ];

      focusBinds = [
        { action = [{ MoveFocusOrTab = "Left"; }]; key = [{ Alt = left; } { Alt = "Left"; }]; }
        { action = [{ MoveFocusOrTab = "Right"; }]; key = [{ Alt = right; } { Alt = "Right"; }]; }
        { action = [{ MoveFocus = "Down"; }]; key = [{ Alt = down; } { Alt = "Down"; }]; }
        { action = [{ MoveFocus = "Up"; }]; key = [{ Alt = up; } { Alt = "Up"; }]; }
      ];

      resizeBinds = [
        { action = [{ Resize = "Increase"; }]; key = [{ Alt = "="; }]; }
        { action = [{ Resize = "Increase"; }]; key = [{ Alt = "+"; }]; }
        { action = [{ Resize = "Decrease"; }]; key = [{ Alt = "-"; }]; }
      ];
    in
    {
      default_shell = "${pkgs.${cfg.defaultShell}}/bin/${cfg.defaultShell}";
      theme = "catppuccin";
      themes = {
        catppuccin = {
          bg = [ 48 45 65 ];
          black = [ 22 19 32 ];
          blue = [ 150 205 251 ];
          cyan = [ 26 24 38 ];
          fg = [ 217 224 238 ];
          gray = [ 87 82 104 ];
          green = [ 171 233 179 ];
          magenta = [ 245 194 231 ];
          orange = [ 248 189 150 ];
          red = [ 242 143 173 ];
          white = [ 217 224 238 ];
          yellow = [ 250 227 176 ];
        };
      };

      plugins = {
        "tab-bar" = { path = "tab-bar"; };
        "status-bar" = { path = "status-bar"; };
        "strider" = { path = "strider"; };
        "compact-bar" = { path = "compact-bar"; };
      };

      keybinds = {
        _properties.clear-defaults = true;
        normal = [
          { action = [{ SwitchToMode = "locked"; }]; key = [{ Ctrl = "g"; }]; }
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
          { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
          { action = [{ SwitchToMode = "Move"; }]; key = [{ Ctrl = "h"; }]; }
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "n"; } "Esc"]; }
          { action = [{ SwitchToMode = "Pane"; }]; key = [{ Ctrl = "p"; }]; }
          { action = [{ SwitchToMode = "Scroll"; }]; key = [{ Ctrl = "s"; }]; }
          { action = [{ SwitchToMode = "Session"; }]; key = [{ Ctrl = "o"; }]; }
          { action = [{ SwitchToMode = "Tab"; }]; key = [{ Ctrl = "t"; }]; }
          { action = [{ SwitchToMode = "Tmux"; }]; key = [{ Ctrl = "a"; }]; }

          { action = [{ Resize = "Increase"; }]; key = [ "=" ]; }
          { action = [{ Resize = "Increase"; }]; key = [ "+" ]; }
          { action = [{ Resize = "Decrease"; }]; key = [ "-" ]; }
          { action = [{ Resize = "Left"; }]; key = [ left "Left" ]; }
          { action = [{ Resize = "Down"; }]; key = [ down "Down" ]; }
          { action = [{ Resize = "Up"; }]; key = [ up "Up" ]; }
          { action = [{ Resize = "Right"; }]; key = [ right "Right" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

        pane = [
          { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
          { action = [{ SwitchToMode = "Move"; }]; key = [{ Ctrl = "h"; }]; }
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "p"; } "Esc"]; }
          { action = [{ SwitchToMode = "RenamePane"; } { PaneNameInput = 0; }]; key = [ "c" ]; }
          { action = [{ SwitchToMode = "Resize"; }]; key = [{ Ctrl = "n"; }]; }
          { action = [{ SwitchToMode = "Scroll"; }]; key = [{ Ctrl = "s"; }]; }
          { action = [{ SwitchToMode = "Session"; }]; key = [{ Ctrl = "o"; }]; }
          { action = [{ SwitchToMode = "Tab"; }]; key = [{ Ctrl = "t"; }]; }
          { action = [{ SwitchToMode = "Tmux"; }]; key = [{ Ctrl = "a"; }]; }

          { action = [ "SwitchFocus" ]; key = [ "p" ]; }
          { action = [{ MoveFocus = "Down"; }]; key = [ down "Down" ]; }
          { action = [{ MoveFocus = "Up"; }]; key = [ up "Up" ]; }
          { action = [{ MoveFocus = "Left"; }]; key = [ left "Left" ]; }
          { action = [{ MoveFocus = "Right"; }]; key = [ right "Right" ]; }

          { action = [{ NewPane = "Left"; } { SwitchToMode = "Normal"; }]; key = [ "n" ]; }
          { action = [{ NewPane = "Down"; } { SwitchToMode = "Normal"; }]; key = [ "d" ]; }
          { action = [{ NewPane = "Right"; } { SwitchToMode = "Normal"; }]; key = [ "r" ]; }
          { action = [ "CloseFocus" { SwitchToMode = "Normal"; } ]; key = [ "x" ]; }
          { action = [ "ToggleFocusFullscreen" { SwitchToMode = "Normal"; } ]; key = [ "f" ]; }
          { action = [ "TogglePaneFrames" { SwitchToMode = "Normal"; } ]; key = [ "z" ]; }
          { action = [ "ToggleFloatingPanes" { SwitchToMode = "Normal"; } ]; key = [ "w" ]; }
          { action = [ "TogglePaneEmbedOrFloating" { SwitchToMode = "Normal"; } ]; key = [ "e" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

        move = [
          { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "h"; } "Esc"]; }
          { action = [{ SwitchToMode = "Pane"; }]; key = [{ Ctrl = "p"; }]; }
          { action = [{ SwitchToMode = "Resize"; }]; key = [{ Ctrl = "n"; }]; }
          { action = [{ SwitchToMode = "Scroll"; }]; key = [{ Ctrl = "s"; }]; }
          { action = [{ SwitchToMode = "Session"; }]; key = [{ Ctrl = "o"; }]; }
          { action = [{ SwitchToMode = "Tab"; }]; key = [{ Ctrl = "t"; }]; }

          { action = [{ MovePane = "Left"; }]; key = [ "n" ]; }
          { action = [{ MovePane = "Left"; }]; key = [ left "Left" ]; }
          { action = [{ MovePane = "Down"; }]; key = [ down "Down" ]; }
          { action = [{ MovePane = "Up"; }]; key = [ up "Up" ]; }
          { action = [{ MovePane = "Right"; }]; key = [ right "Right" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

        tab = [
          { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
          { action = [{ SwitchToMode = "Move"; }]; key = [{ Ctrl = "h"; }]; }
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "t"; } "Esc"]; }
          { action = [{ SwitchToMode = "Pane"; }]; key = [{ Ctrl = "p"; }]; }
          { action = [{ SwitchToMode = "Resize"; }]; key = [{ Ctrl = "n"; }]; }
          { action = [{ SwitchToMode = "Scroll"; }]; key = [{ Ctrl = "s"; }]; }
          { action = [{ SwitchToMode = "Session"; }]; key = [{ Ctrl = "o"; }]; }
          { action = [{ SwitchToMode = "Tmux"; }]; key = [{ Ctrl = "a"; }]; }

          { action = [ "GoToPreviousTab" ]; key = [ left "Left" "Up" up ]; }
          { action = [ "GoToNextTab" ]; key = [ right "Right" "Down" down ]; }
          { action = [ "CloseTab" { SwitchToMode = "Normal"; } ]; key = [ "x" ]; }
          { action = [ "ToggleActiveSyncTab" { SwitchToMode = "Normal"; } ]; key = [ "s" ]; }

          { action = [{ GoToTab = 1; } { SwitchToMode = "Normal"; }]; key = [ "1" ]; }
          { action = [{ GoToTab = 2; } { SwitchToMode = "Normal"; }]; key = [ "2" ]; }
          { action = [{ GoToTab = 3; } { SwitchToMode = "Normal"; }]; key = [ "3" ]; }
          { action = [{ GoToTab = 4; } { SwitchToMode = "Normal"; }]; key = [ "4" ]; }
          { action = [{ GoToTab = 5; } { SwitchToMode = "Normal"; }]; key = [ "5" ]; }
          { action = [{ GoToTab = 6; } { SwitchToMode = "Normal"; }]; key = [ "6" ]; }
          { action = [{ GoToTab = 7; } { SwitchToMode = "Normal"; }]; key = [ "7" ]; }
          { action = [{ GoToTab = 8; } { SwitchToMode = "Normal"; }]; key = [ "8" ]; }
          { action = [{ GoToTab = 9; } { SwitchToMode = "Normal"; }]; key = [ "9" ]; }

          { action = [{ SwitchToMode = "RenameTab"; } { TabNameInput = 0; }]; key = [ "r" ]; }
          { action = [{ NewTab = { }; } { SwitchToMode = "Normal"; }]; key = [ "n" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

        scroll = [
          { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
          { action = [{ SwitchToMode = "Move"; }]; key = [{ Ctrl = "h"; }]; }
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "s"; } "Esc"]; }
          { action = [{ SwitchToMode = "Pane"; }]; key = [{ Ctrl = "p"; }]; }
          { action = [{ SwitchToMode = "Resize"; }]; key = [{ Ctrl = "n"; }]; }
          { action = [{ SwitchToMode = "Session"; }]; key = [{ Ctrl = "o"; }]; }
          { action = [{ SwitchToMode = "Tab"; }]; key = [{ Ctrl = "t"; }]; }
          { action = [{ SwitchToMode = "Tmux"; }]; key = [{ Ctrl = "a"; }]; }

          { action = [ "EditScrollback" { SwitchToMode = "Normal"; } ]; key = [ "e" ]; }
          { action = [ "ScrollToBottom" { SwitchToMode = "Normal"; } ]; key = [{ Ctrl = "c"; }]; }
          { action = [ "ScrollDown" ]; key = [ down "Down" ]; }
          { action = [ "ScrollUp" ]; key = [ up "Up" ]; }
          { action = [ "PageScrollDown" ]; key = [{ Ctrl = "f"; } "PageDown" "Right" right]; }
          { action = [ "PageScrollUp" ]; key = [{ Ctrl = "b"; } "PageUp" "Left" left]; }
          { action = [ "HalfPageScrollDown" ]; key = [ "d" ]; }
          { action = [ "HalfPageScrollUp" ]; key = [ "u" ]; }
        ] ++ defaultBinds;

        renametab = [
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "c"; } "Esc"]; }
          { action = [{ TabNameInput = 27; } { SwitchToMode = "Tab"; }]; key = [ "Esc" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

        renamepane = [
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "c"; } "Esc"]; }
          { action = [{ PaneNameInput = 27; } { SwitchToMode = "Pane"; }]; key = [ "Esc" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

        session = [
          { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
          { action = [{ SwitchToMode = "Move"; }]; key = [{ Ctrl = "h"; }]; }
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "o"; } "Esc"]; }
          { action = [{ SwitchToMode = "Pane"; }]; key = [{ Ctrl = "p"; }]; }
          { action = [{ SwitchToMode = "Resize"; }]; key = [{ Ctrl = "n"; }]; }
          { action = [{ SwitchToMode = "Scroll"; }]; key = [{ Ctrl = "s"; }]; }
          { action = [{ SwitchToMode = "Tab"; }]; key = [{ Ctrl = "t"; }]; }
          { action = [{ SwitchToMode = "Tmux"; }]; key = [{ Ctrl = "a"; }]; }

          { action = [ "Detach" ]; key = [ "d" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

        tmux = [
          { action = [{ SwitchToMode = "Locked"; }]; key = [{ Ctrl = "g"; }]; }
          { action = [{ SwitchToMode = "Move"; }]; key = [{ Ctrl = "h"; }]; }
          { action = [{ SwitchToMode = "Normal"; }]; key = [{ Ctrl = "o"; } "Esc"]; }
          { action = [{ SwitchToMode = "Pane"; }]; key = [{ Ctrl = "p"; }]; }
          { action = [{ SwitchToMode = "RenameTab"; } { TabNameInput = 0; }]; key = [ "," ]; }
          { action = [{ SwitchToMode = "Resize"; }]; key = [{ Ctrl = "n"; }]; }
          { action = [{ SwitchToMode = "Scroll"; }]; key = [{ Ctrl = "s"; }]; }
          { action = [{ SwitchToMode = "Tab"; }]; key = [{ Ctrl = "t"; }]; }

          { action = [{ NewPane = "Down"; } { SwitchToMode = "Normal"; }]; key = [ "-" ]; }
          { action = [{ NewPane = "Right"; } { SwitchToMode = "Normal"; }]; key = [ "|" ]; }
          { action = [{ NewTab = { }; } { SwitchToMode = "Normal"; }]; key = [ "c" ]; }
          { action = [{ Write = 2; } { SwitchToMode = "Normal"; }]; key = [{ Ctrl = "a"; }]; }

          { action = [ "ToggleFocusFullscreen" { SwitchToMode = "Normal"; } ]; key = [ "z" ]; }
          { action = [ "GoToPreviousTab" { SwitchToMode = "Normal"; } ]; key = [ "p" ]; }
          { action = [ "GoToNextTab" { SwitchToMode = "Normal"; } ]; key = [ "n" ]; }

          { action = [{ MoveFocus = "Left"; } { SwitchToMode = "Normal"; }]; key = [ "Left" left ]; }
          { action = [{ MoveFocus = "Right"; } { SwitchToMode = "Normal"; }]; key = [ "Right" right ]; }
          { action = [{ MoveFocus = "Down"; } { SwitchToMode = "Normal"; }]; key = [ "Down" down ]; }
          { action = [{ MoveFocus = "Up"; } { SwitchToMode = "Normal"; }]; key = [ "Up" up ]; }

          { action = [ "FocusNextPane" ]; key = [ "o" ]; }
          { action = [ "Detach" ]; key = [ "d" ]; }
        ] ++ defaultBinds ++ resizeBinds ++ focusBinds;
      };
    };
in
{
  configFile = generate "zellij.kdl" zj_settings;
}
