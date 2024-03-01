{
  description = "TerraVision is a CLI tool that converts Terraform code into Professional Cloud Architecture Diagrams";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (pkgs) python3;
        #  Need the unfree for terraform
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      in
      rec
      {
        formatter = pkgs.nixpkgs-fmt;

        packages = {

          python-hcl2 = import ./python-hcl2.nix {
            setuptools = python3.pkgs.setuptools;
            setuptools-scm = python3.pkgs.setuptools-scm;
            lib = python3.pkgs.lib;
            buildPythonPackage = python3.pkgs.buildPythonPackage;
            fetchPypi = python3.pkgs.fetchPypi;
            lark = python3.pkgs.lark;
            nose = python3.pkgs.nose;
            pythonOlder = python3.pkgs.pythonOlder;
          };

          # https://discourse.nixos.org/t/pip-not-found-by-python39-in-nix-shell/24017/3
          terravision = python3.pkgs.buildPythonPackage rec {
            format = "pyproject";
            name = "terravision";
            src = ./.;
            doCheck = false;
            nativeBuildInputs = with python3.pkgs; [
              setuptools
            ];
            propagatedBuildInputs = [
              pkgs.git
              pkgs.terraform
              pkgs.graphviz
              python3.pkgs.gitpython
              python3.pkgs.clickclick
              python3.pkgs.graphviz
              python3.pkgs.requests
              python3.pkgs.tqdm
              packages.python-hcl2
              python3.pkgs.numpy
              python3.pkgs.debugpy
              python3.pkgs.ipaddr
            ];

          };
          default = self.packages.${system}.terravision;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.terravision ];
          packages = [ pkgs.poetry pkgs.graphviz pkgs.terraform ];
        };
      });
}
