{ lib, callPackage, stdenvNoCC }:
with lib;
let
  # Get this from "flutter doctor"
  version = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";
  sha256 = fakeHash;

  mkPackage = callPackage ./package.nix {};
  runtimeModes = builtins.listToAttrs (builtins.map (runtimeMode: {
    name = runtimeMode;
    value = mkPackage {
      inherit runtimeMode version sha256;
    };
  }) [
    "debug"
    "profile"
    "release"
    "jit_release"
  ]);
in stdenvNoCC.mkDerivation {
  pname = "flutter-engine";
  inherit version;

  passthru = runtimeModes // {
    inherit runtimeModes;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/flutter $out/lib/pkgconfig

    ${concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (runtimeMode: pkg: ''
      cp -r -P --no-preserve=ownership,mode ${pkg}/lib/flutter/${runtimeMode} $out/lib/flutter/${runtimeMode}
      substituteAll ${./flutter-engine.pc} $out/lib/pkgconfig/flutter-engine-${runtimeMode}.pc
    '') runtimeModes))}
  '';

  meta = {
    description = "The engine for Flutter";
    homepage = "https://github.com/flutter/engine";
    license = licenses.bsd3;
    maintainers = with maintainers; [ RossComputerGuy ];
  };
}
