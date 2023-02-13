{ lib, stdenv, writeText }:
with lib;
{ packages ? [], ... }@drv:
let
  pkgGroups = groupBy (drv: drv.pkg.source) packages;
  groups = builtins.mapAttrs (source: packages: groupBy (drv: drv.pkg.name) packages) pkgGroups;
in
stdenv.mkDerivation (builtins.removeAttrs drv [ "passthru" "packages" ] // {
  passthru = (drv.passthru or {}) // {
    inherit packages groups;
  };

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/hosted

    ${concatMapStringsSep "\n" (source: ''
      mkdir -p $out/hosted/${source}/.cache

      ${concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: drvs:
      let
        latest = builtins.elemAt drvs ((builtins.length drvs) - 1);
        mkVersionPubspec = def: {
          inherit (def.pkg) name version description repository environment;
        } // optionalAttrs ((builtins.length (builtins.attrNames def.pkg.dependencies)) > 0) {
          inherit (def.pkg) dependencies;
        } // optionalAttrs ((builtins.length (builtins.attrNames def.pkg.devDependencies)) > 0) {
          dev_dependencies = def.pkg.devDependencies;
        } // optionalAttrs ((builtins.length (builtins.attrNames def.pkg.dependencyOverrides)) > 0) {
          dependency_overrides = def.pkg.dependencyOverrides;
        };

        mkVersion = def: {
          inherit (def.pkg) version;
          pubspec = mkVersionPubspec def;
          archive_url = def.url;
          archive_sha256 = removePrefix "sha256-" def.pkg.sha256;
          published = "1971-01-01T12:00:00.000000";
        };
      in ''
        ${concatMapStringsSep "\n" (drv: ''
          cp -r -P --no-preserve=ownership,mode ${drv} $out/hosted/${drv.pkg.source}/${drv.pkg.name}-${drv.pkg.version}
        '') drvs}

        cp ${writeText "${source}-${name}-versions.json" ''
          {
            "name": "${name}",
            "_fetchedAt": "1971-01-01T12:00:00.000000",
            "latest": ${builtins.toJSON (mkVersion latest)},
            "versions": [
              ${concatMapStringsSep ",\n" (def: builtins.toJSON (mkVersion def)) drvs}
            ]
          }
        ''} $out/hosted/${source}/.cache/${name}-versions.json
      '') groups.${source}))}
    '') (builtins.attrNames groups)}
  '';
})
