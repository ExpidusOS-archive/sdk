{ lib, stdenvNoCC, fetchurl, depot_tools }:
with lib;
let
  inherit (depot_tools) cipd;
in stdenvNoCC.mkDerivation {
  pname = "cipd";
  inherit (cipd) version;

  src = fetchurl {
    name = "cipd-${cipd.platform}-${cipd.version}-unwrapped";
    url = "https://chrome-infra-packages.appspot.com/client?platform=${cipd.platform}&version=${cipd.version}";
    sha256 = cipd.hashes.${cipd.platform};
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp --no-preserve=ownership $src $out/bin/cipd
    chmod +x $out/bin/cipd
  '';

  passthru = { inherit depot_tools; };

  meta = with lib; {
    broken = !(builtins.hasAttr "${cipd.platform}" cipd.hashes);
  };
}
