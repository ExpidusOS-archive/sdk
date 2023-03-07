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
  libxml2,
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
            repository = "https://github.com/dart-lang/args";
            description = "Library for defining parsers for parsing raw command-line arguments into a set of options and values using GNU and POSIX style options.";
            environment.sdk = ">=2.18.0 <3.0.0";
            devDependencies = {
              lints = "^2.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "async";
            version = "2.10.0";
            sha256 = "sha256-3Xky9zLMWKY2rimHQQka6w0Tc40ua9oXq5hJXRX1EAI=";
            repository = "https://github.com/dart-lang/async";
            description = "Utility functions and classes related to the 'dart:async' library.";
            environment.sdk = ">=2.18.0 <3.0.0";
            dependencies = {
              collection = "^1.15.0";
              meta = "^1.1.7";
            };
            devDependencies = {
              fake_async = "^1.2.0";
              lints = "^2.0.0";
              stack_trace = "^1.10.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "cli_util";
            version = "0.3.5";
            sha256 = "sha256-Rg6eBlrq556Lq3BoEWWlZo+cQ55sVNpweemzywpzswY=";
            repository = "https://github.com/dart-lang/cli_util";
            description = "A library to help in building Dart command-line apps.";
            environment.sdk = ">=2.18.0 <3.0.0";
            dependencies = {
              meta = "^1.3.0";
              path = "^1.8.0";
            };
            devDependencies = {
              lints = "^1.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "collection";
            version = "1.17.1";
            sha256 = "sha256-bY5gKplieuYGbbFC9SbwuyHYHiG9jMaZqbQer4Vxyb8=";
            repository = "https://github.com/dart-lang/collection";
            description = "Collections and utilities functions and classes related to collections.";
            environment.sdk = ">=2.18.0 <3.0.0";
            devDependencies = {
              lints = "^2.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "ffi";
            version = "2.0.1";
            sha256 = "sha256-qeQpj1MgJ69LxGzHSaiKMBIoAaMsYjr/xyWa1h5HxAg=";
            repository = "https://github.com/dart-lang/ffi";
            description = "Utilities for working with Foreign Function Interface (FFI) code.";
            environment.sdk = ">=2.17.0 <3.0.0";
            devDependencies = {
              test = "^1.21.2";
              lints = "^2.0.0";
            };
          })
          (fetchFromPubdev {
            name = "ffigen";
            version = "7.2.1";
            sha256 = "sha256-XGE7zSpWVBu/kFCPL3oYS/YwtoVJVDbB0TkiU6s9xUQ=";
            repository = "https://github.com/dart-lang/ffigen";
            description = "Generator for FFI bindings, using LibClang to parse C header files.";
            environment.sdk = ">=2.17.0 <3.0.0";
            dependencies = {
              ffi = "^2.0.1";
              yaml = "^3.0.0";
              path = "^1.8.0";
              quiver = "^3.0.0";
              args = "^2.0.0";
              logging = "^1.0.0";
              cli_util = "^0.3.0";
              glob = "^2.0.0";
              file = "^6.0.0";
              package_config = "^2.1.0";
              yaml_edit = "^2.0.3";
            };
            devDependencies = {
              lints = "^1.0.1";
              test = "^1.16.2";
            };
          })
          (fetchFromPubdev {
            name = "file";
            version = "6.1.4";
            sha256 = "sha256-Z9477phM5lac1RIcylEDGyzQYF7zPx0ui4005OhyTCo=";
            repository = "https://github.com/google/file.dart/tree/master/packages/file";
            description = "A pluggable, mockable file system abstraction for Dart. Supports local file system access, as well as in-memory file systems, record-replay file systems, and chroot file systems.";
            environment.sdk = ">=2.12.0 <3.0.0";
            dependencies = {
              meta = "^1.3.0";
              path = "^1.8.0";
            };
            devDependencies = {
              file_testing = "^3.0.0";
              lints = "^1.0.1";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "glob";
            version = "2.1.1";
            sha256 = "sha256-SwPNnriP3R8JXffTpt4i1jwKQJc+Nhkyp+Z19BSL26g=";
            repository = "https://github.com/dart-lang/glob";
            description = "A library to perform Bash-style file and directory globbing.";
            environment.sdk = ">=2.15.0 <3.0.0";
            dependencies = {
              async = "^2.5.0";
              collection = "^1.15.0";
              file = "^6.1.3";
              path = "^1.8.0";
              string_scanner = "^1.1.0";
            };
            devDependencies = {
              lints = "^1.0.0";
              test = "^1.17.0";
              test_descriptor = "^2.0.0";
            };
          })
          (fetchFromPubdev {
            name = "js";
            version = "0.6.5";
            sha256 = "sha256-oNiUJsfKHOKJM7K/OqwbIo25SSLmVdX3r8vs8Pzry40=";
            repository = "https://github.com/dart-lang/sdk/tree/main/pkg/js";
            description = "Annotations to create static Dart interfaces for JavaScript APIs.";
            environment.sdk = ">=2.19.0 <3.0.0";
            dependencies.meta = "^1.7.0";
            devDependencies.lints = "any";
          })
          (fetchFromPubdev {
            name = "logging";
            version = "1.1.1";
            sha256 = "sha256-BFoLSsb7080C/d8xC1uVh7+IQtO3KNKMbFgJs5g/xSA=";
            repository = "https://github.com/dart-lang/logging";
            description = "Provides APIs for debugging and error logging, similar to loggers in other languages, such as the Closure JS Logger and java.util.logging.Logger.";
            environment.sdk = ">=2.18.0 <3.0.0";
            devDependencies = {
              lints = "^2.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "matcher";
            version = "0.12.14";
            sha256 = "sha256-Mnlinnwtp2eKwuUncsSf2nH2mlcwotwkQb06Kp6Vdr8=";
            repository = "https://github.com/dart-lang/matcher";
            description = "Support for specifying test expectations via an extensible Matcher class. Also includes a number of built-in Matcher implementations for common cases.";
            environment.sdk = ">=2.18.0 <3.0.0";
            dependencies = {
              meta = "^1.8.0";
              stack_trace = "^1.10.0";
            };
            devDependencies = {
              lints = "^2.0.0";
              test = "any";
              test_api = "any";
              test_core = "any";
            };
            dependencyOverrides.test_api = "any";
          })
          (fetchFromPubdev {
            name = "meta";
            version = "1.9.0";
            sha256 = "sha256-Eo/YauGJNG6bmpr+sBN6PRqrWGXGlIh0mfZ0E+X5PY8=";
            repository = "https://github.com/dart-lang/sdk/tree/main/pkg/meta";
            description = "Annotations used to express developer intentions that can't otherwise be deduced by statically analyzing source code.";
            environment.sdk = ">=2.12.0 <3.0.0";
            devDependencies.lints = "any";
          })
          (fetchFromPubdev {
            name = "package_config";
            version = "2.1.0";
            sha256 = "sha256-7K6jYIDvUAAxBn0OYGWIgc8rXoa6uELkJ2T4xUgElLQ=";
            repository = "https://github.com/dart-lang/package_config";
            description = "Support for reading and writing Dart Package Configuration files.";
            environment.sdk = ">=2.12.0 <3.0.0";
            dependencies.path = "^1.8.0";
            devDependencies = {
              build_runner = "^2.0.0";
              build_test = "^2.1.2";
              build_web_compilers = "^3.0.0";
              lints = "^1.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "path";
            version = "1.8.3";
            sha256 = "sha256-O5JyRH8NTWnNBq+eS5Qmg7Ml9FS2igvzTNF87QSGTdY=";
            repository = "https://github.com/dart-lang/path";
            description = "A string-based path manipulation library. All of the path operations you know and love, with solid support for Windows, POSIX (Linux and Mac OS X), and the web.";
            environment.sdk = ">=2.12.0 <3.0.0";
            devDependencies = {
              lints = "^1.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "quiver";
            version = "3.2.1";
            sha256 = "sha256-AAVL6eUrcejUMMqDfrgJnNjyG+t6ykaPxYxoSBSP6F4=";
            repository = "https://github.com/google/quiver-dart";
            description = "Quiver is a set of utility libraries for Dart that makes using many Dart libraries easier and more convenient, or adds additional functionality.";
            environment.sdk = ">=2.17.0 <3.0.0";
            dependencies.matcher = "^0.12.10";
            devDependencies = {
              lints = "^2.0.0";
              path = "^1.8.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "source_span";
            version = "1.9.1";
            sha256 = "sha256-Bq1s4Ax7I9svyfxLe3IKGZtwEaHGycjS1rgETo/XBNM=";
            repository = "https://github.com/dart-lang/source_span";
            description = "A library for identifying source spans and locations.";
            environment.sdk = ">=2.14.0 <3.0.0";
            dependencies = {
              collection = "^1.15.0";
              path = "^1.8.0";
              term_glyph = "^1.2.0";
            };
            devDependencies = {
              lints = "^1.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "stack_trace";
            version = "1.11.0";
            sha256 = "sha256-yooEjFq7ju0pmTv+wb4qhIGZSiI52kXEx9vleffG7y0=";
            repository = "https://github.com/dart-lang/stack_trace";
            description = "A package for manipulating stack traces and printing them readably.";
            environment.sdk = ">=2.18.0 <3.0.0";
            dependencies.path = "^1.8.0";
            devDependencies = {
              lints = "^2.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "string_scanner";
            version = "1.2.0";
            sha256 = "sha256-AETXoJlFtOf7KdF0dvsHNQhnWL1g5gGe41sNkcQGOVw=";
            repository = "https://github.com/dart-lang/string_scanner";
            description = "A class for parsing strings using a sequence of patterns.";
            environment.sdk = ">=2.18.0 <3.0.0";
            dependencies.source_span = "^1.8.0";
            devDependencies = {
              lints = "^2.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "term_glyph";
            version = "1.2.1";
            sha256 = "sha256-CXbKc4omicY/DeJxI+Fu3Zdy/QDnViW7BpoypvrVFvU=";
            repository = "https://github.com/dart-lang/term_glyph";
            description = "Useful Unicode glyphs and ASCII substitutes.";
            environment.sdk = ">=2.12.0 <3.0.0";
            devDependencies = {
              csv = "^5.0.0";
              dart_style = "^2.0.0";
              lints = "^1.0.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "web_ffi";
            version = "0.7.2";
            sha256 = "sha256-X8NAXeXy5Jv3xCKP8HGjBD6ZdPeeGSyjW/LA5HMIBUI=";
            repository = "https://github.com/EPNW/web_ffi/";
            description = "Translates dart:ffi calls on the web to WebAssembly using dart:js";
            environment.sdk = ">=2.12.0 <3.0.0";
            dependencies = {
              js = "^0.6.3";
              meta = "^1.3.0";
            };
          })
          (fetchFromPubdev {
            name = "yaml";
            version = "3.1.1";
            sha256 = "sha256-PIJ7f1/nTAVTPodUasba5vodvhNh1F4WGjknNuyvGFc=";
            repository = "https://github.com/dart-lang/yaml";
            description = "A parser for YAML, a human-friendly data serialization standard";
            environment.sdk = ">=2.12.0 <3.0.0";
            dependencies = {
              collection = "^1.15.0";
              source_span = "^1.8.0";
              string_scanner = "^1.1.0";
            };
            devDependencies = {
              lints = "^1.0.0";
              path = "^1.8.0";
              test = "^1.16.0";
            };
          })
          (fetchFromPubdev {
            name = "yaml_edit";
            version = "2.0.3";
            sha256 = "sha256-0IG/5jdOqv08tdwKYT86ADHmwMNWegGORpe5Ww/6hxg=";
            repository = "https://github.com/dart-lang/yaml_edit";
            description = "A library for YAML manipulation with comment and whitespace preservation.";
            environment.sdk = ">=2.12.0 <3.0.0";
            dependencies = {
              collection = "^1.15.0";
              meta = "^1.7.0";
              source_span = "^1.8.1";
              yaml = "^3.1.0";
            };
            devDependencies = {
              lints = "^1.0.1";
              path = "^1.8.0";
              test = "^1.17.12";
            };
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

      buildInputs = featureInputs
        ++ optional (libxkbcommon.meta.available) libxkbcommon
        ++ optional (stdenv.isLinux) systemd
        ++ optional (wayland.meta.available) wayland
        ++ optional (!bootstrap) libxml2;
    in stdenv.mkDerivation {
      pname = "neutron${optionalString bootstrap "-bootstrap"}";
      version = "git+${builtins.substring 0 7 rev}";

      inherit src buildInputs;
      PUB_CACHE = dartPackages;

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

      propagatedBuildInputs = filter (drv: drv != check) buildInputs;
      doCheck = features'.tests.value;

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

      postInstall = optionalString (!bootstrap) ''
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
