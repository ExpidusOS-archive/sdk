{ pkgs, stdenv ? pkgs.stdenv, fileName ? "expidusos-system-${stdenv.hostPlatform.system}", contents, storeContents ? [], extraCommands ? "", extraArgs ? "", compressCommand ? "pixz", compressionExtension ? ".xz", extraInputs ? [ pkgs.pixz ], ... }:
import ((import ../../lib/nixpkgs.nix) + "/nixos/lib/make-system-tarball.nix") {
  inherit (pkgs) closureInfo pixz;
  inherit fileName contents storeContents extraCommands extraArgs compressCommand compressionExtension extraInputs stdenv;
}
