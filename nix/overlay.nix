nix-filter:

final: prev:
{
  ocaml-ng = builtins.mapAttrs (_: ocamlVersion:
    ocamlVersion.overrideScope' (oself: osuper: {
      json-logs-reporter = prev.callPackage ./default.nix { inherit nix-filter; };
    })) prev.ocaml-ng;
}