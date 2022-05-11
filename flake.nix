{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    let
      overlay = import ./nix/overlay.nix nix-filter;
      out = system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          devShells.default = (pkgs.mkShell {
            inputsFrom = [ self.packages."${system}".ocamlPackages ];
            buildInputs = with pkgs;
              with ocamlPackages; [
                ocaml-lsp
                ocamlformat
                odoc
                ocaml
                dune_3
                nixfmt
              ];
          });

          packages = pkgs.lib.mapAttrs (version: ocamlPackages:
            (pkgs.callPackage ./nix { inherit nix-filter ocamlPackages; }))
            (builtins.removeAttrs pkgs.ocaml-ng [
              "overrideDerivation"
              "override"
              "ocamlPackages_4_00_1"
              "ocamlPackages_4_01_0"
              "ocamlPackages_4_02"
              "ocamlPackages_4_03"
              "ocamlPackages_4_04"
              "ocamlPackages_4_05"
              "ocamlPackages_4_06"
              "ocamlPackages_4_07"
              "ocamlPackages_4_08"
              "ocamlPackages_4_09"
            ]);
        };
    in with flake-utils.lib;
    eachSystem defaultSystems out // {
      overlays.default = overlay;
      hydraJobs = {
        x86_64-linux.default = self.packages.x86_64-linux;
        aarch64-darwin.default = self.packages.aarch64-darwin;
      };
    };

}
