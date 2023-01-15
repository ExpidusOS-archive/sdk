{ clang14Stdenv, flutter, expidus }:
{ name,
  src,
  runtime ? expidus.runtimes,
  nativeBuildInputs ? [],
  buildInputs ? [],
  passthru ? {},
  meta ? {}
}@args:
clang14Stdenv.mkDerivation ({
  inherit name src meta;

  nativeBuildInputs = [ flutter ] ++ nativeBuildInputs;
  buildInputs = [ runtime ] ++ buildInputs;

  passthru = passthru // {
    expidus-runtime = runtime;
  };
} // (builtins.removeAttrs args [ "nativeBuildInputs" "buildInputs" "meta" "name" "src" "runtime" ]))
