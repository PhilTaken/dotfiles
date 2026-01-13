{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  cloudscraper,
}:

buildHomeAssistantComponent rec {
  owner = "greghesp";
  domain = "bambu_lab";
  version = "2.0.40";

  src = fetchFromGitHub {
    owner = "greghesp";
    repo = "ha-bambulab";
    rev = "v${version}";
    sha256 = "sha256-ygbNq7B/ZBQ8/al9ADPSru+VpzmMESwxhKA0YkKKOrE=";
  };

  dependencies = [
    cloudscraper
  ];
}
