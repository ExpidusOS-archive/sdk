let
  pkgs = import ../../.. { };
in
pkgs.mkShell {
  name = "expidus-manual";

  packages = with pkgs; [ xmlformat jing xmloscopy ruby ];
}
