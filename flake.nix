{
  description = "TerraVision is a CLI tool that converts Terraform code into Professional Cloud Architecture Diagrams";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:danieroux/nixpkgs";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    poetry2nix = {
      # Awaiting: https://github.com/nix-community/poetry2nix/pull/1543
      url = "github:danieroux/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (pkgs) python3;
        # https://stackoverflow.com/a/77838280
        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
        #  Need the unfree for terraform
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      in
      rec
      {
        formatter = pkgs.nixpkgs-fmt;

        packages = {

          terravision = poetry2nix.mkPoetryApplication {
            projectDir = self;
            propagatedBuildInputs = [ pkgs.git pkgs.graphviz pkgs.terraform ];
            overrides = poetry2nix.overrides.withDefaults (final: prev: {
              python-hcl2 = pkgs.python3.pkgs.python-hcl2;
            });

            # Or, use the wheel
            #            overrides = poetry2nix.overrides.withDefaults (final: prev: {
            #              python-hcl2 = prev.python-hcl2.override {
            #                preferWheel = true;
            #              };
            #            });
          };

          default = self.packages.${system}.terravision;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.terravision ];
          packages = [ pkgs.poetry ];
        };
      });
}
