{ lib, stdenvNoCC, writeText, cipd, cacert }:
with lib;
{ name ? "source", package, version, sha256 ? fakeHash }:
stdenvNoCC.mkDerivation {
  pname = name;
  inherit version;
  builder = ./builder.sh;

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeBuildInputs = [ cipd ];

  ensureFile = writeText "${name}-ensure" ''
    $OverrideInstallMode copy

    @Subdir src
    ${package} ${version}
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = sha256;
}
