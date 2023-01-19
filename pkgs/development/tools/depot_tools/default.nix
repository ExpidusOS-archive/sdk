{ lib, stdenvNoCC, targetPlatform, fetchgit }:
with lib;
let
  rev = "25cf78395cd77e11b13c1bd26124e0a586c19166";

  cipd-platform-arch = if targetPlatform.isi686 then "386"
  else if targetPlatform.isS390 && targetPlatform.is64Bit then "s390x"
  else if targetPlatform.isx86_64 then "amd64"
  else "${targetPlatform.parsed.cpu.family}${if targetPlatform.is64Bit then "64" else "32"}${if (targetPlatform.parsed.cpu.family == "mips" or targetPlatform.isPower64) and targetPlatform.isLittleEndian then "le" else "" }";

  cipd-platform-kernel = if targetPlatform.isLinux or targetPlatform.isDarwin or targetPlatform.isWindows then
    (if targetPlatform.isDarwin then "mac" else targetPlatform.parsed.kernel.name)
  else throw "Unsupported kernel ${targetPlatform.parsed.kernel.name}";
in stdenvNoCC.mkDerivation rec {
  pname = "depot_tools";
  version = "git+${rev}";

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromium/tools/depot_tools.git";
    inherit rev;
    sha256 = "sha256-Qn0rqX2+wYpbyfwYzeaFsbsLvuGV6+S9GWrH3EqaHmU=";
  };

  passthru.cipd = {
    version = readFile "${src}/cipd_client_version";
    hashes = builtins.listToAttrs (map (line:
      let
        segments = builtins.split " +" line;
      in { name = builtins.head segments; value = lib.last segments; })
    (lib.filter (line: !(hasPrefix "#" line || line == "")) (splitString "\n" (readFile "${src}/cipd_client_version.digests"))));
    platform = "${cipd-platform-kernel}-${cipd-platform-arch}";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r -P --no-preserve=ownership $src $out
  '';
}
