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
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        packages = {
          terravision = mkPoetryApplication {
            projectDir = self;
          };
          default = self.packages.${system}.terravision;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.terravision ];
          packages = [ pkgs.poetry ];
        };
      });
}
