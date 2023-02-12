{ lib,
  buildDartVendor,
  fetchFromPubdev,
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

      dartPackages = buildDartVendor {
        pname = "neutron${optionalString bootstrap "-bootstrap"}-dart-vendor";
        version = "git+${builtins.substring 0 7 rev}";

        packages = [
          (fetchFromPubdev {
            name = "args";
            version = "2.3.2";
            sha256 = "sha256-VddOHZcSf0b4kQ26afb7WjwIj++SIapzEfnKHDWViis=";
          })
          (fetchFromPubdev {
            name = "async";
            version = "2.10.0";
            sha256 = "sha256-3Xky9zLMWKY2rimHQQka6w0Tc40ua9oXq5hJXRX1EAI=";
          })
          (fetchFromPubdev {
            name = "cli_util";
            version = "0.3.5";
            sha256 = "sha256-Rg6eBlrq556Lq3BoEWWlZo+cQ55sVNpweemzywpzswY=";
          })
          (fetchFromPubdev {
            name = "collection";
            version = "1.17.1";
            sha256 = "sha256-bY5gKplieuYGbbFC9SbwuyHYHiG9jMaZqbQer4Vxyb8=";
          })
          (fetchFromPubdev {
            name = "ffi";
            version = "2.0.1";
            sha256 = "sha256-qeQpj1MgJ69LxGzHSaiKMBIoAaMsYjr/xyWa1h5HxAg=";
          })
          (fetchFromPubdev {
            name = "ffigen";
            version = "7.2.1";
            sha256 = "sha256-XGE7zSpWVBu/kFCPL3oYS/YwtoVJVDbB0TkiU6s9xUQ=";
          })
          (fetchFromPubdev {
            name = "file";
            version = "6.1.4";
            sha256 = "sha256-Z9477phM5lac1RIcylEDGyzQYF7zPx0ui4005OhyTCo=";
          })
          (fetchFromPubdev {
            name = "glob";
            version = "2.1.1";
            sha256 = "sha256-SwPNnriP3R8JXffTpt4i1jwKQJc+Nhkyp+Z19BSL26g=";
          })
          (fetchFromPubdev {
            name = "js";
            version = "0.6.5";
            sha256 = "sha256-oNiUJsfKHOKJM7K/OqwbIo25SSLmVdX3r8vs8Pzry40=";
          })
          (fetchFromPubdev {
            name = "logging";
            version = "1.1.1";
            sha256 = "sha256-BFoLSsb7080C/d8xC1uVh7+IQtO3KNKMbFgJs5g/xSA=";
          })
          (fetchFromPubdev {
            name = "matcher";
            version = "0.12.14";
            sha256 = "sha256-Mnlinnwtp2eKwuUncsSf2nH2mlcwotwkQb06Kp6Vdr8=";
          })
          (fetchFromPubdev {
            name = "meta";
            version = "1.9.0";
            sha256 = "sha256-Eo/YauGJNG6bmpr+sBN6PRqrWGXGlIh0mfZ0E+X5PY8=";
          })
          (fetchFromPubdev {
            name = "package_config";
            version = "2.1.0";
            sha256 = "sha256-7K6jYIDvUAAxBn0OYGWIgc8rXoa6uELkJ2T4xUgElLQ=";
          })
          (fetchFromPubdev {
            name = "path";
            version = "1.8.3";
            sha256 = "sha256-O5JyRH8NTWnNBq+eS5Qmg7Ml9FS2igvzTNF87QSGTdY=";
          })
          (fetchFromPubdev {
            name = "quiver";
            version = "3.2.1";
            sha256 = "sha256-AAVL6eUrcejUMMqDfrgJnNjyG+t6ykaPxYxoSBSP6F4=";
          })
          (fetchFromPubdev {
            name = "source_span";
            version = "1.9.1";
            sha256 = "sha256-Bq1s4Ax7I9svyfxLe3IKGZtwEaHGycjS1rgETo/XBNM=";
          })
          (fetchFromPubdev {
            name = "stack_trace";
            version = "1.11.0";
            sha256 = "sha256-yooEjFq7ju0pmTv+wb4qhIGZSiI52kXEx9vleffG7y0=";
          })
          (fetchFromPubdev {
            name = "string_scanner";
            version = "1.2.0";
            sha256 = "sha256-AETXoJlFtOf7KdF0dvsHNQhnWL1g5gGe41sNkcQGOVw=";
          })
          (fetchFromPubdev {
            name = "term_glyph";
            version = "1.2.1";
            sha256 = "sha256-CXbKc4omicY/DeJxI+Fu3Zdy/QDnViW7BpoypvrVFvU=";
          })
          (fetchFromPubdev {
            name = "web_ffi";
            version = "0.7.2";
            sha256 = "sha256-X8NAXeXy5Jv3xCKP8HGjBD6ZdPeeGSyjW/LA5HMIBUI=";
          })
          (fetchFromPubdev {
            name = "yaml";
            version = "3.1.1";
            sha256 = "sha256-PIJ7f1/nTAVTPodUasba5vodvhNh1F4WGjknNuyvGFc=";
          })
          (fetchFromPubdev {
            name = "yaml_edit";
            version = "2.0.3";
            sha256 = "sha256-0IG/5jdOqv08tdwKYT86ADHmwMNWegGORpe5Ww/6hxg=";
          })
        ];
      };

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
      featureInputs = lists.flatten (builtins.attrValues (builtins.mapAttrs (name: option: option.inputs or (if builtins.hasAttr "input" option then [ option.input ] else [])) featuresEnabled));

      nativeFeatureInputs = lists.flatten (builtins.attrValues (builtins.mapAttrs (name: option: option.nativeInputs or (if builtins.hasAttr "nativeInput" option then [ option.nativeInput ] else [])) featuresEnabled));
    in stdenv.mkDerivation {
      pname = "neutron${optionalString bootstrap "-bootstrap"}";
      version = "git+${builtins.substring 0 7 rev}";

      inherit src dartPackages;

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
        ++ optional (libxkbcommon.meta.available) libxkbcommon
        ++ optional (stdenv.isLinux) systemd
        ++ optional (wayland.meta.available) wayland;
      doCheck = features'.tests.value;

      postUnpack = ''
        ln -s $dartPackages $NIX_BUILD_TOP/.pub-dev
      '';

      mesonBuildType = buildType;
      mesonFlags = mesonFlags ++ [
        "-Dgit-commit=${builtins.substring 0 7 rev}"
        "-Dgit-branch=${branch}"
        "-Dbootstrap=${if bootstrap then "true" else "false"}"
        "-Dflutter-engine=${if isWASM then buildPackages.flutter-engine else flutter-engine}/lib/flutter/out/${engineType}"
        "-Ddart-offline=true"
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
          pkgconfig = ['${emscripten}/bin/emmake', 'env', 'PKG_CONFIG_PATH=${concatMapStringsSep ":" (pkg: "${if builtins.hasAttr "dev" pkg then pkg.dev else pkg}/lib/pkgconfig") (featureInputs ++ nativeFeatureInputs)}', '${pkg-config}/bin/pkg-config']
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
          default_library = 'static'

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
