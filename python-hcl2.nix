# _Not_
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/python-modules/bc-python-hcl2/default.nix

{ setuptools
, setuptools-scm
, lib
, buildPythonPackage
, fetchPypi
, lark
, nose
, pythonOlder
}:

buildPythonPackage rec {
  pname = "python-hcl2";
  version = "4.3.2";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cSJmFDi+J8zYuPPbcZadjvLM47PPGD6I+BcldedAWmU=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    lark
  ];

  pythonImportsCheck = [
    "hcl2"
  ];

  meta = with lib; {
    description = "Parser for HCL2 written in Python using Lark";
    longDescription = ''
      This parser only supports HCL2 and isn't backwards compatible with HCL v1.
      It can be used to parse any HCL2 config file such as Terraform.
    '';
    homepage = "https://github.com/amplify-education/python-hcl2";
    license = licenses.mit;
    #    maintainers = with maintainers; [ danieroux ];
  };
}
