{ lib, config, ... }:
pkgs: super:
with pkgs;
let
  isCrossCompiling = stdenv.hostPlatform != stdenv.buildPlatform;
in
rec {
  inherit lib;
  path = lib.expidus.channels.sdk;

  nix = super.nix.overrideAttrs (old: {
    doInstallCheck = !isCrossCompiling;
  });

  nwg-drawer = callPackage ../applications/misc/nwg-drawer/default.nix {};

  ninja = super.ninja.overrideAttrs (old: {
    depsBuildBuild = [ buildPackages.stdenv.cc ];

    postPatch = ''
      # write rebuild args to file after bootstrap
      substituteInPlace configure.py --replace "subprocess.check_call(rebuild_args)" "open('rebuild_args','w').write(rebuild_args[0])"
    '';

    buildPhase = ''
      runHook preBuild
      # for list of env vars
      # see https://github.com/ninja-build/ninja/blob/v1.11.1/configure.py#L264
      CXX="$CXX_FOR_BUILD" \
      AR="$AR_FOR_BUILD" \
      CFLAGS="$CFLAGS_FOR_BUILD" \
      CXXFLAGS="$CXXFLAGS_FOR_BUILD" \
      LDFLAGS="$LDFLAGS_FOR_BUILD" \
      python configure.py --bootstrap
      python configure.py
      source rebuild_args

      # "./ninja -vn manual" output copied here to support cross compilation.
      asciidoc -b docbook -d book -o build/manual.xml doc/manual.asciidoc
      xsltproc --nonet doc/docbook.xsl build/manual.xml > doc/manual.html

      runHook postBuild
    '';
  });

  grim = super.grim.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ wayland-scanner ];
  });

  elfutils = super.elfutils.overrideAttrs (old: {
    buildInputs = old.buildInputs
      ++ lib.optionals (with stdenv; !cc.isGNU && !(isDarwin && isAarch64)) [ libgcc ];
  });
}
