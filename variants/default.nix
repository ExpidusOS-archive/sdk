{ channels, lib ? import ../lib/extend.nix channels }:
rec {
  mkMainline = import ./mainline { inherit channels lib; };
}
