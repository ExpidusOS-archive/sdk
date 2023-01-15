{ lib, clang14Stdenv, flutter, expidus }:
{ src,
  postUnpack ? "",
  runtime ? expidus.runtimes,
  plugins ? {},
  nativeBuildInputs ? [],
  buildInputs ? [],
  passthru ? {},
  meta ? {}
}@args:
with lib; clang14Stdenv.mkDerivation ({
  inherit src;

  nativeBuildInputs = [ flutter ] ++ nativeBuildInputs;
  buildInputs = [ runtime ] ++ buildInputs;

  flutterPlugins = concatStringsSep "\n" (mapAttrsToList (name: value: "${name}=${value}") (builtins.removeAttrs plugins [ "expidus_runtime" ] // {
    expidus_runtime = runtime;
  }));

  postUnpack = ''
    echo "$flutterPlugins" >.flutter-plugins
  '' ++ (optionalString (postUnpack != "" && postUnpack != null) postUnpack);

  passthru = passthru // {
    expidus-runtime = runtime;
  };

  meta = {
    platforms = builtins.attrValues (lib.expidus.system.default.forAllSystems (system: _: system));
  } // meta;
} // (builtins.removeAttrs args [ "nativeBuildInputs" "buildInputs" "meta" "src" "runtime" "postUnpack" "plugins" ]))
