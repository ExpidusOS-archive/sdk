{ lib, stdenv }:
with lib;
{ packages ? [], ... }@drv:
stdenv.mkDerivation (builtins.removeAttrs drv [ "packages" ] // {
  inherit packages;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/hosted

    ${concatMapStringsSep "\n" (drv: ''
      mkdir -p $out/hosted/${drv.pkg.source}
      cp -r -P --no-preserve=ownership,mode ${drv} $out/hosted/${drv.pkg.source}/${drv.pkg.name}-${drv.pkg.version}
    '') packages}
  '';
})
