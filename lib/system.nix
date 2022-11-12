{ lib }:
rec {
  current = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else "x86_64-linux";

  supported = lib.platforms.unix;
  forAllLinux = lib.genAttrs lib.platforms.linux;
  forAll = lib.genAttrs supported;
}
