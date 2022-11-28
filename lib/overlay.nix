{ nixpkgs, ... }@channels: (import (nixpkgs + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix channels;
  platforms = prev.platforms // {
    mesaPlatforms = prev.platforms.mesaPlatforms ++ [ "riscv32-linux" ];
  };
})
