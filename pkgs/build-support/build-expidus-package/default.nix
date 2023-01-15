{ lib, clang14Stdenv, flutter, expidus }:
{ exec,
  src,
  postUnpack ? "",
  runtime ? expidus.runtimes,
  plugins ? {},
  nativeBuildInputs ? [],
  buildInputs ? [],
  passthru ? {},
  meta ? {}
}@args:
with lib;
let
  platform = "linux"; # FIXME: use targetPlatform
  arch = "x64"; # FIXME: use targetPlatform
in clang14Stdenv.mkDerivation ({
  inherit src;

  nativeBuildInputs = [ flutter ] ++ nativeBuildInputs;
  buildInputs = [ runtime ] ++ buildInputs;

  flutterPlugins = concatStringsSep "\n" (mapAttrsToList (name: value: "${name}=${value}") (builtins.removeAttrs plugins [ "expidus_runtime" ] // {
    expidus_runtime = runtime;
  }));

  postUnpack = ''
    echo "$flutterPlugins" >.flutter-plugins
  '' ++ (optionalString (postUnpack != "" && postUnpack != null) postUnpack);

  configurePhase = ''
    flutter pub get
  '';

  buildPhase = ''
    flutter build ${platform}
  '';

  installPhase = ''
    mkdir -p $out/lib/$name
    cp -r build/${platform}/${arch}/bundle $out/lib/$name

    wrapProgram $out/lib/$name/${exec} \
      --suffix LD_LIBRARY_PATH : "$out/lib/$name/lib"
  '';

  passthru = passthru // {
    expidus-runtime = runtime;
  };

  meta = {
    platforms = builtins.attrValues (lib.expidus.system.default.forAllSystems (system: _: system));
  } // meta;
} // (builtins.removeAttrs args [ "nativeBuildInputs" "buildInputs" "meta" "src" "runtime" "postUnpack" "plugins" "exec" ]))
