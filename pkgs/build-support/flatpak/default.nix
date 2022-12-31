{ stdenvNoCC, writeScriptBin, flatpakDir, targetPlatform, bubblewrap, flatpak, cacert }:
let
  wrapFlatpakLauncher = name: app: runtime:
    writeScriptBin name ''
      export FLATPAK_DIR=${flatpakDir}
      ${bubblewrap}/bin/bwrap \
        --dev-bind / / \
        --tmpfs $FLATPAK_DIR \
        --ro-bind ${app} $FLATPAK_DIR/app \
        --ro-bind ${runtime} $FLATPAK_DIR/runtime \
        ${flatpak}/bin/flatpak --user run ${name}
    '';

  fetchFromFlatHub = { name, runtime ? null, ref, commit, sha256 }:
    stdenvNoCC.mkDerivation {
      nativeBuildInputs = [ flatpak cacert bubblewrap ];

      runtime = if runtime != null then runtime else "";
      builder = ./jump-to-fetch-flatpak.sh;
      fetcher = ./fetch-flatpak.sh;
    
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = sha256;

      inherit name ref commit;
    };

  fetchRuntimeFromFlatHub = { name, arch ? targetPlatform.linuxArch, branch, commit, sha256 }:
    fetchFromFlatHub { ref = "${name}/${arch}/${branch}"; inherit name commit sha256; };

  fetchAppFromFlatHub = { name, arch ? targetPlatform.linuxArch, branch ? "stable", runtime, commit, sha256 }:
    fetchFromFlatHub { ref = "${name}/${arch}/${branch}"; inherit name runtime commit sha256; };
in {
  inherit wrapFlatpakLauncher fetchFromFlatHub fetchRuntimeFromFlatHub fetchAppFromFlatHub;
}
