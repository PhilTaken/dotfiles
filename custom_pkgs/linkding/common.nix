{
  lib,
  fetchFromGitHub,
}: let
  version = "v1.31.0";
in {
  inherit version;

  npmDepsHash = "sha256-EtIdcw+26OVvnmcDtfpqCNZBdYPtUaOSOr6hO+ULLns=";

  src = fetchFromGitHub {
    owner = "sissbruecker";
    repo = "linkding";
    rev = version;
    sha256 = "sha256-sTDI36XeoeT0l8Pb0058Mjas4O74pVg1ovLIFvh1Gik=";
  };

  meta = with lib; {
    homepage = "https://github.com/sissbruecker/linkding";
    license = licenses.mit;
  };
}
