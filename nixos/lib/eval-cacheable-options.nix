{ libPath, ... }@args:
let
  nixpkgs = import (libPath + "/nixpkgs.nix");
in import (nixpkgs + "/nixos/lib/eval-cacheable-options.nix") args
