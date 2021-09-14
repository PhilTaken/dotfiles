{ lib
, python3Packages
,
}:
python3Packages.buildPythonApplication rec {
  version = "1.12.0";
  pname = "fortran-language-server";
  src = builtins.fetchGit {
    url = "https://github.com/hansec/fortran-language-server.git";
    rev = "22ceea4b7e3ff713df71e42521ced3f144ec9dbe";
  };
  propagatedBuildInputs = [ python3Packages.setuptools ];
}
