nixpkgsPath:
let
  lib = import (nixpkgsPath + "/lib/default.nix");
in
{
  inherit nixpkgsPath;

  maintainers = import ./maintainers.nix;
  trivial = import ./trivial.nix { inherit lib; };
}
