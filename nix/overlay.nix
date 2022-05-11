nix-filter:

final: prev: {
  ocaml-ng = (prev.lib.mapAttrs (_: ocamlVersion:
    ocamlVersion.overrideScope' (oself: osuper: {
      json-logs-reporter = (final.callPackage ./default.nix {
        inherit nix-filter;
        ocamlPackages = osuper;
      });
    })) (builtins.removeAttrs prev.ocaml-ng [
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
    ]));
}
