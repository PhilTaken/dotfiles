let
  inherit (builtins) filter isString split baseNameOf getEnv stringLength readFile listToAttrs map replaceStrings elemAt;

  repofile = getEnv "REPOFILE";
  paths = filter (s: isString s && stringLength s > 0) (split "\n" (readFile repofile));
in {
  dbpath = "${getEnv "XDG_DATA_HOME"}/hound/db";
  repos = listToAttrs (map (entry: let
      parts = filter isString (split " " entry);
      repo_path = elemAt parts 0;
      url = elemAt parts 1;

      # split the "git.*@" and the ".git" from git ssh urls
      url_base_raw = elemAt (split ".git" (elemAt (split "@" url) 2)) 0;
      url_base = replaceStrings [":"] ["/"] url_base_raw;
    in {
      name = baseNameOf repo_path;
      value = {
        inherit url;
        enable-poll-updates = false;
        enable-push-updates = false;
        url-pattern = {
          base-url = "https://${url_base}/-/blob/{rev}/{path}{anchor}";
          anchor = "#L{line}";
        };
        vcs-config.detect-ref = true;
      };
    })
    paths);
}
