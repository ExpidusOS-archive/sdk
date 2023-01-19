{ lib, stdenvNoCC, fetchurl, fetchFromGitHub, clang14Stdenv, targetPlatform,
  cmake, ninja, unzip, flutter, xorg, wlroots, llvmPackages_14, pkg-config,
  libdrm, udev, vulkan-loader, mesa }:
{
  rev,
  sha256,
  engine ? {
    rev = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";
    sha256 = "sha256-rpxp0rVv17ObYECx0W0SH7Ai8le869of/dLMT88wh74=";
  }
}: let
  flutterArch = if targetPlatform.isx86_64 then "x64"
    else if targetPlatform.isx86 then "i386"
    else lib.throw "Unsupported system: ${targetPlatform.system}";

  flutter-engine = stdenvNoCC.mkDerivation rec {
    pname = "flutter-engine";
    version = "git+${engine.rev}";

    src = fetchurl {
      curlOptsList = [ "-L" ];
      url = "https://storage.googleapis.com/flutter_infra_release/flutter/${engine.rev}/${targetPlatform.parsed.kernel.name}-${flutterArch}/${targetPlatform.parsed.kernel.name}-${flutterArch}-embedder";
      inherit (engine) sha256;
      name = "${targetPlatform.parsed.kernel.name}-${flutterArch}-embedder.zip";
    };

    outputs = [ "out" "dev" ];

    nativeBuildInputs = [ unzip ];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/lib $dev/lib/pkgconfig $dev/include
      cd $out/lib && unzip $src
      mv $out/lib/flutter_embedder.h $dev/include/flutter_embedder.h

      substituteAll ${./flutter_embedder.pc} $dev/lib/pkgconfig/flutter_embedder.pc
    '';
  };
in clang14Stdenv.mkDerivation {
  pname = "expidus-runtime";
  version = "git+${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "runtime";
    inherit rev sha256;
    leaveDotGit = true;
  };

  nativeBuildInputs = [ flutter cmake ninja pkg-config llvmPackages_14.clang llvmPackages_14.llvm ];
  buildInputs = [ flutter-engine ]
    ++ (lib.optionals (clang14Stdenv.isLinux) [ wlroots xorg.libxcb libdrm udev vulkan-loader mesa ] ++ libdrm.buildInputs);

  dontConfigure = true;
  dontBuild = true;

  passthru = {
    inherit flutter-engine;
  };

  installPhase = ''
    cp -r -P --no-preserve=mode,ownership $src $out
    rm -rf $out/example $out/flake.nix $out/flake.lock
  '';

  meta = with lib; {
    description = "Various runtime environments for applications on ExpidusOS";
    homepage = "https://github.com/ExpidusOS/runtimes";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ RossComputerGuy ];
    platforms = builtins.attrValues (lib.expidus.system.default.forAllSystems (system: _: system));
  };
}
