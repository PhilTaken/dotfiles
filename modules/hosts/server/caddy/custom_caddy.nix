{ lib
, fetchFromGitHub

, buildGoModule

, caddy
, plugins ? [ ]
, vendorSha256 ? lib.fakeSha256
}:

with lib;

let
  imports = flip concatMapStrings plugins ({ name, version }: "\t_ \"${name}\"\n");
  gogets = flip concatMapStrings plugins ({ name, version }: "go get \"${name}@${version}\"");

  pname = "caddy";
  version = "2.5.2";
  main = ''
    package main

    import (
        caddycmd "github.com/caddyserver/caddy/v2/cmd"

        // plug in Caddy modules here
        _ "github.com/caddyserver/caddy/v2/modules/standard"
        ${imports}
    )

    func main() {
        caddycmd.Main()
    }
  '';

in
if plugins == [ ]
then caddy
else
  caddy.override {
    buildGoModule = args:
      buildGoModule (args // {
        inherit vendorSha256;

        passthru.plugins = plugins;

        pname = "${pname}-with-plugins";

        overrideModAttrs = _: {
          preBuild = ''
            echo '${main}' > cmd/caddy/main.go
            ${gogets}
          '';
          postInstall = "cp go.sum go.mod $out/";
        };

        postPatch = ''
          echo '${main}' > cmd/caddy/main.go
        '';

        postConfigure = "cp vendor/go.sum vendor/go.mod .";
      });
  }
