{ lib, stdenvNoCC, clang14Stdenv, runCommandNoCC, writeText, yj, jq, remarshal, flutter, expidus }:
{ src,
  runtime ? expidus.runtime,
  plugins ? {},
  nativeBuildInputs ? [],
  buildInputs ? [],
  passthru ? {},
  meta ? {},
  ...
}@args:
with lib;
let
  src = stdenvNoCC.mkDerivation ({
    inherit (args) src;

    nativeBuildInputs = [ remarshal yj jq ];

    buildCommand = ''
      cp -r -P --no-preserve=mode,ownership $src $out
      yj < $out/pubspec.yaml > $out/pubspec.json

      ${concatStringsSep "\n" (attrValues (builtins.mapAttrs (name: value: ''
        jq --arg name "${name}" --arg value "${value}" -r '.dependencies[$name].path |= $value' $out/pubspec.json >$out/pubspec.json.tmp
        mv $out/pubspec.json.tmp $out/pubspec.json
      '') (plugins // {
        expidus_runtime = runtime;
      })))}

      json2yaml -i $out/pubspec.json -o $out/pubspec.yaml
      rm $out/pubspec.json
    '';

    dontInstall = true;
  } // args);

  pubspec' = strings.fromJSON (readFile (runCommandNoCC "pubspec.json" {} ''
    ${yj}/bin/yj < "${src}/pubspec.yaml" > $out
  ''));

  args' = builtins.removeAttrs args [ "src" "flutterPlugins" "plugins" "passthru" "buildInputs" "nativeBuildInputs" ];
in flutter.mkFlutterApp ({
  inherit src;

  nativeBuildInputs = runtime.nativeBuildInputs ++ nativeBuildInputs;
  buildInputs = [ runtime ] ++ buildInputs;

  passthru = passthru // {
    expidus-runtime = runtime;
    inherit pubspec;
  };

  meta = {
    platforms = builtins.attrValues (lib.expidus.system.default.forAllSystems (system: _: system));
  } // meta;
} // args')
