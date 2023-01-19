{ lib, callPackage }:
with lib;
let
  pkg = callPackage ./package.nix {};
in pkg {
  rev = "53cff094977eca64d590ce68785016e3c2ffad11";
  sha256 = "sha256-/CwZq75QWLNxHd+zi6XeNv6+dmn5xCKQcZ6DuMw70ys=";
}
