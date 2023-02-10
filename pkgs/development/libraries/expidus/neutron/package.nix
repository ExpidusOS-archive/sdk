{ lib,
  fetchFromGitHub,
  writeText,
  stdenv,
  buildPackages, 
  targetPlatform,
  check,
  flutter-engine,
  libglvnd,
  pixman,
  xorg,
  wlroots,
  wayland,
  libxkbcommon,
  systemd,
  isWASM
}@pkgs:
with lib;
let
  optionalPkg = pkg: optional pkg.meta.available pkg;
  mesonFeature = b: if b then "enabled" else "disabled";

  mkPackage = {
    rev ? "HEAD",
    branch ? "master",
    src ? fetchFromGitHub {
      owner = "ExpidusOS";
      repo = "neutron";
      inherit rev sha256;
    },
    isWASM ? (pkgs.isWASM or false),
    wasmParsed ? (if targetPlatform.isWasm then targetPlatform.parsed else systems.parse.mkSystemFromString "wasm32-unknown-wasi"),
    features ? {},
    bootstrap ? false,
    mesonFlags ? [],
    passthru ? {},
    engineType ? "release",
    buildType ? "release",
    sha256 ? fakeHash
  }@args:
    let
      isWASM = args.isWASM or false;

      mkSimpleFeat = input: {
        default = input.meta.available;
        inherit input;
      };

      mkNonWASMFearure = input: value: {
        default = if isWASM then value else input.meta.available;
        inherit input;
      };

      featdefs = {
        docs = {
          default = if isWASM then false else buildPackages.gtk-doc.meta.available;
          nativeInputs = with buildPackages; [
            gtk-doc
            libxslt
            docbook_xsl
            docbook_xml_dtd_412
            docbook_xml_dtd_42
            docbook_xml_dtd_43
          ];
        };
        tests = mkNonWASMFearure check false;
        displaykit-compositor-xcb = mkNonWASMFearure xorg.libxcb false;
        displaykit-compositor-wlroots = mkNonWASMFearure wlroots false;
        displaykit-client-xcb = mkNonWASMFearure xorg.libxcb false;
        graphics-renderer-egl = {
          default = if isWASM then true else libglvnd.meta.available;
          inputs = if isWASM then [] else [ libglvnd ];
        };
        graphics-renderer-pixman = mkNonWASMFearure pixman false;
      };

      features' = builtins.mapAttrs (name: def:
        let
          value = features.${name} or def.default;
        in {
          inherit value;
        } // def) featdefs;

      featuresEnabled = filterAttrs (name: option: option.value) features';

      featureFlags = builtins.attrValues (builtins.mapAttrs (name: option: "-D${name}=${mesonFeature option.value}") features');
      featureInputs = lists.flatten (builtins.attrValues (builtins.mapAttrs (name: option: option.inputs or (if "input" ? option then [ option.input ] else [])) featuresEnabled));

      nativeFeatureInputs = lists.flatten (builtins.attrValues (builtins.mapAttrs (name: option: option.nativeInputs or (if "nativeInput" ? option then [ option.nativeInput ] else [])) featuresEnabled));
    in stdenv.mkDerivation {
      pname = "neutron${optionalString bootstrap "-bootstrap"}";
      version = "git+${builtins.substring 0 7 rev}";

      inherit src;

      outputs = [ "out" "dev" ]
        ++ optional (features'.docs.value) "devdoc";

      nativeBuildInputs = with buildPackages; ([
        buildPackages.expidus.sdk
        meson
        ninja
        pkg-config
      ] ++ optionals (!bootstrap) [
        buildPackages.flutter.dart
      ] ++ optionals (wayland.meta.available && !bootstrap) [
        wayland-protocols
      ] ++ nativeFeatureInputs);

      buildInputs = featureInputs
        ++ optional (stdenv.isLinux) systemd
        ++ optional (wayland.meta.available) wayland;
      doCheck = features'.tests.value;

      mesonBuildType = buildType;
      mesonFlags = mesonFlags ++ [
        "-Dgit-commit=${builtins.substring 0 7 rev}"
        "-Dgit-branch=${branch}"
        "-Dbootstrap=${if bootstrap then "true" else "false"}"
        "-Dflutter-engine=${if isWASM then buildPackages.flutter-engine else flutter-engine}/lib/flutter/out/${engineType}"
      ] ++ featureFlags
        ++ optional (isWASM) "--cross-file=${writeText "neutron.cross" (with pkgs.buildPackages.buildPackages; ''
          [constants]
          cflags = []
          ldflags = ['-v', '-s', 'WASM=1']

          [binaries]
          cmake = ['${emscripten}/bin/emcmake', '${cmake}/bin/cmake']
          ar = '${emscripten}/bin/emar'
          c = '${emscripten}/bin/emcc'
          c_ld = '${llvmPackages_14.bintools-unwrapped}/bin/wasm-ld'
          cpp = '${emscripten}/bin/em++'
          cpp_ld = '${llvmPackages_14.bintools-unwrapped}/bin/wasm-ld'
          ranlib = '${emscripten}/bin/emranlib'
          pkgconfig = ['${emscripten}/bin/emmake', 'env', 'PKG_CONFIG_PATH=${concatMapStringsSep ":" (pkg: "${if "dev" ? pkg then pkg.dev else pkg}/lib/pkgconfig") (featureInputs ++ nativeFeatureInputs)}', '${pkg-config}/bin/pkg-config']
          file_packager = '${emscripten}/share/emscripten/tools/file_packager'

          [properties]
          needs_exe_wrapper = true
          exe_suffix = 'js'
          static_library_suffix = 'la'
          shared_library_suffix = 'js'
          shared_module_suffix = 'js'

          [built-in options]
          c_args = cflags
          c_link_args = ldflags

          [host_machine]
          system = 'emscripten'
          cpu_family = '${wasmParsed.cpu.name}'
          cpu = '${wasmParsed.cpu.family}'
          endian = '${strings.removeSuffix "Endian" wasmParsed.cpu.significantByte.name}'
        '')}";

      postInstall = ''
        mkdir -p $dev/lib
        mv $out/lib/neutron $dev/lib/neutron
      '';

      passthru = passthru // {
        inherit mkPackage rev branch isWASM;
        features = features';
      } // optionalAttrs (!bootstrap) {
        bootstrap = mkPackage (args // {
          bootstrap = true;
        });
      };

      meta = {
        description = "Core API for ExpidusOS";
        homepage = "https://github.com/ExpidusOS/neutron";
        license = licenses.gpl3Only;
        maintainers = with maintainers; [ RossComputerGuy ];
      };
    };
in mkPackage
