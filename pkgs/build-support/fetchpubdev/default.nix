{ fetchurl, runCommandNoCC }:
{ name, version, sha256, description ? "", repository, environment ? {}, dependencies ? {}, devDependencies ? {}, dependencyOverrides ? {} }@args:
fetchurl {
  pname = "${name}-source";
  url = "https://pub.dev/packages/${name}/versions/${version}.tar.gz";
  inherit sha256 version;

  downloadToTemp = true;
  recursiveHash = true;

  passthru = {
    pkg = {
      inherit name version sha256 description repository environment dependencies devDependencies dependencyOverrides;
      source = "pub.dartlang.org";
    };
  };

  postFetch = ''
    mkdir -p $out
    tar -xf $downloadedFile -C $out
  '';
}
