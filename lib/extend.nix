let
  lib = import ((import ./nixpkgs.nix) + "/lib/default.nix");
in
{
  maintainers = import ./maintainers.nix;
  trivial = import ./trivial.nix { inherit lib; };
}
