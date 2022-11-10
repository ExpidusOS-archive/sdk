{ nixpkgsPath, ... }@channels: (import (nixpkgsPath + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix channels;
})
