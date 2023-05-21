{}
#{ inputs
#, config
#, pkgs
#, lib
#, ...
#}:
#let
#cfg = config.services.easyeffects;
#l = builtins // lib;
#inherit (l)
#mkOption mkIf readDir filterAttrs foldl'
#recursiveUpdate attrNames setAttrByPath hasInfix
#splitString last removeSuffix removePrefix
#escapeShellArg listToAttrs head toInt imap0
#length attrValues mapAttrs' elem;
#inherit (l.types) listOf enum;
## TODO:
## - literally include floats, don't treat float string as string that needs to be escaped
## - generate reduced set of 32 bands for easyeffects config
## - generate in ci without needing to have huge autoeq repo as input
#getPresetName = file: (removeSuffix " GraphicEQ.txt" (last (splitString "/" file)));
#defaultBand = {
#mode = "RLC (BT)";
#mute = false;
#q = 4.36;
#slope = "x1";
#solo = false;
#type = "Bell";
#};
#templateWithBands = bands: {
#output = {
#blocklist = [];
#"equalizer#0" = {
#balance = 1.;
#bypass = false;
#input-gain = 2.0;
#left = bands;
#right = bands;
#mode = "FFT";
#num-bands = length (attrValues bands);
#output-gain = 2.3;
#pitch-left = 0.0;
#pitch-right = 0.0;
#split-channels = false;
#};
#plugins_order = [
#"equalizer#0"
#];
#};
#};
#mkPresetFromFile = file: let
#content = builtins.readFile file;
#paramLines = splitString "; " (removePrefix "GraphicEQ: " content);
#bands = listToAttrs (imap0 (i: line: let
#foo = splitString " " line;
#in {
#name = "band#${toString i}";
#value = recursiveUpdate defaultBand {
#frequency = toInt (head foo);
#gain = last foo;
#};
#}) paramLines);
#in builtins.toJSON (templateWithBands bands);
#listRecursive = pathStr: listRecursive' { } pathStr;
#listRecursive' = acc: pathStr:
#let
#path = pathStr;
#toPath = s: path + "/${s}";
#contents = readDir path;
#dirs = filterAttrs (k: v: v == "directory") contents;
#files = filterAttrs (k: v: v == "regular" && hasInfix "GraphicEQ" k) contents;
#dirs' = foldl'
#(acc: d: recursiveUpdate acc (listRecursive (pathStr + "/" + d)))
#{ }
#(attrNames dirs);
#files' = foldl'
#(acc: f:
#recursiveUpdate acc (setAttrByPath [
#(getPresetName f)
#]
#(mkPresetFromFile (toPath f))))
#{ }
#(attrNames files);
#in
#recursiveUpdate dirs' files';
#allPresets = listRecursive "${inputs.autoeq}/results";
#selectedPresets = filterAttrs (n: _: elem n cfg.presets) allPresets;
#configFiles = mapAttrs' (n: v: { name = "easyeffects/output/${escapeShellArg n}.json"; value.text = v; }) selectedPresets;
#in {
#options.services.easyeffects = {
#presets = mkOption {
#type = listOf (enum (builtins.attrNames allPresets));
#default = [];
#};
#};
#config = mkIf cfg.enable {
#xdg.configFile = configFiles;
#};
#}

