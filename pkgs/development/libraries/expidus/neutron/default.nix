{ callPackage, stdenv, zig }:
callPackage ./package.nix {
  inherit stdenv zig;
} {
  rev = "f15dedc4f9b74b6ae9074d6b3cd9c1a4102e1135";
  sha256 = "sha256-ew6TmAYdXBBXnrYlSxu1jOE17EN0axLDoptlfoDqYOI=";
}
