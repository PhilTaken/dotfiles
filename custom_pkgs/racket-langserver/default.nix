# WIP
{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation {
  pname = "racket-langserver";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "jeapostrophe";
    repo = "racket-langserver";
    rev = "3447fe6b5091c78f9807bcaf6ee7640c862a9484";
    sha256 = "049wkw40jyd6zivn7c7wahwicfb5lbaj5vrfn1gsvk1z9yh8yp1s";
  };

  buildPhase = ''
    mkdir -p $out/bin
    echo "echo test" > $out/bin/racket-langserver
    chmod +x $out/bin/racket-langserver
  '';
}
