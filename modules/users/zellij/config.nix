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

      concatAttrList = args: lib.concatStrings (lib.intersperse "\n" (map (tabstr depth) args));
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
      #default_shell = if (cfg.defaultShell == null) then "$SHELL" else "${pkgs.${cfg.defaultShell}}/bin/${cfg.defaultShell}";
      pane_frames = false;
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

      keybinds =
        let
          modelist = map lib.toLower (builtins.attrNames config);
          modes = lib.genAttrs modelist (n: n);
          swToModes = lib.mapAttrs (n: _: { SwitchToMode = modes.${n}; }) modes;

          swToModesBinds = modes:
            let
              swToMode = action: lib.concatStrings (map (elem: elem.SwitchToMode or "") action);

              filter = elem:
                let
                  newMode = swToMode elem.action;
                in
                if (builtins.typeOf modes == "list") then
                  builtins.elem newMode modes
                else
                  modes == newMode;
            in
            lib.filter filter [
              { action = [ swToModes.normal ]; key = [{ Ctrl = "g"; } "Esc"]; }
              { action = [ swToModes.locked ]; key = [{ Ctrl = "g"; }]; }
              { action = [ swToModes.pane ]; key = [{ Ctrl = "p"; }]; }
              { action = [ swToModes.move ]; key = [{ Ctrl = "h"; }]; }
              { action = [ swToModes.scroll ]; key = [{ Ctrl = "s"; }]; }
              { action = [ swToModes.tab ]; key = [{ Ctrl = "t"; }]; }
              { action = [ swToModes.tmux ]; key = [{ Ctrl = "a"; }]; }
              { action = [ swToModes.resize ]; key = [{ Ctrl = "n"; }]; }
              { action = [ swToModes.session ]; key = [{ Ctrl = "o"; }]; }
              { action = [ swToModes.renamepane ]; key = [ "," ]; }
              { action = [ swToModes.renametab ]; key = [ "$" ]; }
            ];

          config = {
            _properties.clear-defaults = true;
            locked = swToModesBinds (with modes; [ normal pane move resize scroll session tab ]) ++ defaultBinds ++ resizeBinds ++ focusBinds;
            normal = swToModesBinds (with modes; [ locked tmux ]);

            resize = swToModesBinds (with modes; [ normal move scroll session tab pane ]) ++ [
              { action = [{ Resize = "Increase"; }]; key = [ "=" ]; }
              { action = [{ Resize = "Increase"; }]; key = [ "+" ]; }
              { action = [{ Resize = "Decrease"; }]; key = [ "-" ]; }
              { action = [{ Resize = "Left"; }]; key = [ left "Left" ]; }
              { action = [{ Resize = "Down"; }]; key = [ down "Down" ]; }
              { action = [{ Resize = "Up"; }]; key = [ up "Up" ]; }
              { action = [{ Resize = "Right"; }]; key = [ right "Right" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            pane = swToModesBinds (with modes; [ normal move scroll session tab resize renamepane ]) ++ [
              { action = [ "SwitchFocus" ]; key = [ "p" ]; }
              { action = [{ MoveFocus = "Down"; }]; key = [ down "Down" ]; }
              { action = [{ MoveFocus = "Up"; }]; key = [ up "Up" ]; }
              { action = [{ MoveFocus = "Left"; }]; key = [ left "Left" ]; }
              { action = [{ MoveFocus = "Right"; }]; key = [ right "Right" ]; }

              { action = [{ NewPane = "Left"; } swToModes.normal]; key = [ "n" ]; }
              { action = [{ NewPane = "Down"; } swToModes.normal]; key = [ "d" ]; }
              { action = [{ NewPane = "Right"; } swToModes.normal]; key = [ "r" ]; }
              { action = [ "CloseFocus" swToModes.normal ]; key = [ "x" ]; }
              { action = [ "ToggleFocusFullscreen" swToModes.normal ]; key = [ "f" ]; }
              { action = [ "TogglePaneFrames" swToModes.normal ]; key = [ "z" ]; }
              { action = [ "ToggleFloatingPanes" swToModes.normal ]; key = [ "w" ]; }
              { action = [ "TogglePaneEmbedOrFloating" swToModes.normal ]; key = [ "e" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            move = swToModesBinds (with modes; [ normal pane resize scroll session tab ]) ++ [
              { action = [{ MovePane = "Left"; }]; key = [ "n" ]; }
              { action = [{ MovePane = "Left"; }]; key = [ left "Left" ]; }
              { action = [{ MovePane = "Down"; }]; key = [ down "Down" ]; }
              { action = [{ MovePane = "Up"; }]; key = [ up "Up" ]; }
              { action = [{ MovePane = "Right"; }]; key = [ right "Right" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            tab = swToModesBinds (with modes; [ normal move pane resize scroll session renametab ]) ++ [
              { action = [ "GoToPreviousTab" ]; key = [ left "Left" "Up" up ]; }
              { action = [ "GoToNextTab" ]; key = [ right "Right" "Down" down ]; }
              { action = [ "CloseTab" swToModes.normal ]; key = [ "x" ]; }
              { action = [ "ToggleActiveSyncTab" swToModes.normal ]; key = [ "s" ]; }

              { action = [{ GoToTab = 1; } swToModes.normal]; key = [ "1" ]; }
              { action = [{ GoToTab = 2; } swToModes.normal]; key = [ "2" ]; }
              { action = [{ GoToTab = 3; } swToModes.normal]; key = [ "3" ]; }
              { action = [{ GoToTab = 4; } swToModes.normal]; key = [ "4" ]; }
              { action = [{ GoToTab = 5; } swToModes.normal]; key = [ "5" ]; }
              { action = [{ GoToTab = 6; } swToModes.normal]; key = [ "6" ]; }
              { action = [{ GoToTab = 7; } swToModes.normal]; key = [ "7" ]; }
              { action = [{ GoToTab = 8; } swToModes.normal]; key = [ "8" ]; }
              { action = [{ GoToTab = 9; } swToModes.normal]; key = [ "9" ]; }
              { action = [{ NewTab = { }; } swToModes.normal]; key = [ "n" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            scroll = swToModesBinds (with modes; [ normal move pane resize session tab ]) ++ [
              { action = [ "EditScrollback" swToModes.normal ]; key = [ "e" ]; }
              { action = [ "ScrollToBottom" swToModes.normal ]; key = [{ Ctrl = "c"; }]; }
              { action = [ "ScrollDown" ]; key = [ down "Down" ]; }
              { action = [ "ScrollUp" ]; key = [ up "Up" ]; }
              { action = [ "PageScrollDown" ]; key = [{ Ctrl = "f"; } "PageDown" "Right" right]; }
              { action = [ "PageScrollUp" ]; key = [{ Ctrl = "b"; } "PageUp" "Left" left]; }
              { action = [ "HalfPageScrollDown" ]; key = [ "d" ]; }
              { action = [ "HalfPageScrollUp" ]; key = [ "u" ]; }
            ] ++ defaultBinds;

            renametab = swToModesBinds (with modes; [ normal ]) ++ [
              { action = [{ TabNameInput = 27; } swToModes.tab]; key = [ "Esc" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            renamepane = swToModesBinds (with modes; [ normal ]) ++ [
              { action = [{ PaneNameInput = 27; } swToModes.pane]; key = [ "Esc" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            session = swToModesBinds (with modes; [ normal move pane resize scroll tab ]) ++ [
              { action = [ "Detach" ]; key = [ "d" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;

            tmux = swToModesBinds (with modes; [ normal renamepane renametab ]) ++ [
              { action = [{ NewPane = "Down"; } swToModes.normal]; key = [ "-" ]; }
              { action = [{ NewPane = "Right"; } swToModes.normal]; key = [ "|" ]; }
              { action = [{ NewTab = { }; } swToModes.normal]; key = [ "c" ]; }
              { action = [{ Write = 1; } swToModes.normal]; key = [{ Ctrl = "a"; }]; }

              { action = [ "ToggleFocusFullscreen" swToModes.normal ]; key = [ "z" ]; }
              { action = [ "EditScrollback" swToModes.normal ]; key = [ "s" ]; }

              { action = [ "GoToPreviousTab" swToModes.normal ]; key = [{ Ctrl = "y"; }]; }
              { action = [ "GoToNextTab" swToModes.normal ]; key = [{ Ctrl = "o"; }]; }

              { action = [{ Resize = "Left"; }]; key = [ "Y" ]; }
              { action = [{ Resize = "Down"; }]; key = [ "N" ]; }
              { action = [{ Resize = "Up"; }]; key = [ "E" ]; }
              { action = [{ Resize = "Right"; }]; key = [ "O" ]; }

              { action = [{ MoveFocus = "Left"; } swToModes.normal]; key = [ "Left" left ]; }
              { action = [{ MoveFocus = "Right"; } swToModes.normal]; key = [ "Right" right ]; }
              { action = [{ MoveFocus = "Down"; } swToModes.normal]; key = [ "Down" down ]; }
              { action = [{ MoveFocus = "Up"; } swToModes.normal]; key = [ "Up" up ]; }

              { action = [ "Detach" ]; key = [ "d" ]; }
            ] ++ defaultBinds ++ resizeBinds ++ focusBinds;
          };
        in
        config;
    };
in
{
  configFile = generate "zellij.kdl" zj_settings;
}
