{
  description = "TerraVision is a CLI tool that converts Terraform code into Professional Cloud Architecture Diagrams";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        poetry2nix = {
          url = "github:danieroux/poetry2nix";
          inputs.nixpkgs.follows = "nixpkgs";
        };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
       inherit (pkgs) python3;
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
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

          terravision = mkPoetryApplication {
            projectDir = self;
            propagatedBuildInputs = [ pkgs.git pkgs.graphviz pkgs.terraform ];
          };
          default = self.packages.${system}.terravision;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.terravision ];
          packages = [ pkgs.poetry ];
        };
      });
}
