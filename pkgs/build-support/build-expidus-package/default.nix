{ lib, clang14Stdenv, flutter, expidus }:
{ src,
  postUnpack ? "",
  runtime ? expidus.runtime,
  plugins ? {},
  buildInputs ? [],
  passthru ? {},
  meta ? {},
  ...
}@args:
with lib;
flutter.mkFlutterApp ({
  inherit src;

  buildInputs = [ runtime ] ++ buildInputs;

  flutterPlugins = concatStringsSep "\n" (mapAttrsToList (name: value: "${name}=${value}") (builtins.removeAttrs plugins [ "expidus_runtime" ] // {
    expidus_runtime = runtime;
  }));

  postUnpack = ''
    echo "$flutterPlugins" >.flutter-plugins
    ${postUnpack}
  '';

  passthru = passthru // {
    expidus-runtime = runtime;
  };

  meta = {
    platforms = builtins.attrValues (lib.expidus.system.default.forAllSystems (system: _: system));
  } // meta;
} // (builtins.removeAttrs args [ "postUnpack" "src" "flutterPlugins" "plugins" "passthru" "buildInputs" ]))
