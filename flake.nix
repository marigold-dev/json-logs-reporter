{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    let
      out = system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in {
          devShells.default = (pkgs.mkShell {
            inputsFrom = [ self.packages."${system}".default ];
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

          packages.default = (pkgs.callPackage ./nix {
            inherit nix-filter;
          });
        };
    in with flake-utils.lib;
      eachSystem defaultSystems out // {
        overlays.default = (import ./nix/overlay.nix nix-filter);
        hydraJobs = {
          x86_64-linux = self.packages.x86_64-linux.default;
          aarch64-darwin = self.packages.aarch64-darwin.default;
        };
      };

}
