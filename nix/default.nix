{ pkgs, stdenv, ocamlPackages, nix-filter, doCheck ? true }:

with ocamlPackages;
buildDunePackage rec {
  pname = "json-logs-reporter";
  version = "0.1.0";

  src = nix-filter.lib.filter {
    root = ./..;
    name = pname;
    include = [
      (nix-filter.lib.inDirectory "example")
      (nix-filter.lib.inDirectory "src")
      "./dune-project"
      "./json-logs-reporter.opam"
    ];
  };

  propagatedBuildInputs = [ yojson logs fmt ptime ppx_here ];

  inherit doCheck;

  meta = { description = "JSON reporter for Logs"; };
}
