{ lib }:
rec {
  current = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else "x86_64-linux";

  linux = [ "aarch64-linux" "i686-linux" "x86_64-linux" "armv6l-linux" "armv7a-linux" "armv7l-linux" ];
  supported = linux ++ [ "aarch64-darwin" "x86_64-darwin" ];
  forAllLinux = lib.genAttrs linux;
  forAll = lib.genAttrs supported;
}
