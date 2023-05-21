{
  lib,
  buildGoModule,
  caddy,
  plugins ? [],
  vendorHash ? lib.fakeSha256,
  ...
}: let
  inherit (lib) concatMapStrings flip;
  imports = flip concatMapStrings plugins ({name, ...}: "\t_ \"${name}\"\n");
  gogets = flip concatMapStrings plugins ({
    name,
    version,
  }: "go get \"${name}@${version}\"");

  pname = "caddy";
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
  if plugins == []
  then caddy
  else
    caddy.override {
      buildGoModule = args:
        buildGoModule (args
          // {
            inherit vendorHash;

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
