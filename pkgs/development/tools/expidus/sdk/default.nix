{ lib, stdenvNoCC, targetPlatform, bash, yq-go, llvmPackages_14, clang14Stdenv, gcc-unwrapped, gcc, dart, flutter }:
let
  llvmPackages = llvmPackages_14;
  clangStdenv = clang14Stdenv;
in
with lib;
stdenvNoCC.mkDerivation {
  pname = "expidus-sdk";
  inherit (expidus.trivial) version;

  src = expidus.channels.expidus-sdk;

  dontConfigure = true;
  dontBuild = true;

  tools = [
    ./tools/ffigen-config.sh
    ./tools/ffigen.sh
  ];

  inherit bash dart;
  yq = yq-go;

  includePaths = with clang14Stdenv; [
    "${cc.libc.dev}/include"
    "${cc.libc.dev.linuxHeaders}/include"
    "${gcc-unwrapped}/lib/gcc/${targetPlatform.config}/${gcc.version}/include"
  ];

  llvmPaths = with llvmPackages; [
    llvm
    llvm.dev
    llvm.lib
    libclang
    libclang.dev
    libclang.lib
  ];

  installPhase = ''
    mkdir -p $out/bin
    for tool in $tools; do
      binname=$(stripHash $(basename $tool))
      binname=''${binname/.sh/}

      echo "Installing tool $binname"
      substituteAll $tool $out/bin/$binname
      chmod +x $out/bin/$binname
    done
  '';

  meta = {
    description = "Development tools for ExpidusOS";
    homepage = "https://github.com/ExpidusOS/sdk";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ RossComputerGuy ];
    inherit (dart.meta) platforms;
  };
} // optionalAttrs (flutter.meta.available) {
  inherit flutter;
}
