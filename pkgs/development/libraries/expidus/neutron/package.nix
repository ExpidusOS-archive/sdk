{ lib,
  fetchFromGitHub,
  fetchFromGitLab,
  makeWrapper,
  stdenv,
  buildPlatform,
  buildPackages,
  targetPlatform,
  flutter-engine,
  zig
}@pkgs:
with lib;
let
  mkPackage = {
    rev ? "HEAD",
    branch ? "master",
    src ? fetchFromGitHub {
      owner = "ExpidusOS";
      repo = "neutron";
      inherit rev sha256;
    },
    zig ? pkgs.zig,
    enableDocs ? true,
    vendorOverride ? {},
    engineType ? "release",
    buildType ? "ReleaseFast",
    sha256 ? fakeHash,
    target ? "${targetPlatform.system}-gnu"
  }@args:
    let
      args' = {
        rev = "HEAD";
        branch = "master";
        src = fetchFromGitHub {
          owner = "ExpidusOS";
          repo = "neutron";
          inherit (args') rev sha256;
        };
        zig = pkgs.zig;
        enableDocs = true;
        vendorOverride = {};
        engineType = "release";
        buildType = "ReleaseFast";
        sha256 = fakeHash;
        target = "${targetPlatform.system}-gnu";
      } // args;

      vendor = {
        "os-specific/linux/libs/drm" = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "drm";
          rev = "ee558cea20d1f9d822fe1a28e97beaf365bf9d38";
          sha256 = "sha256-Ju9QbbsjDW4f9lFfClqlWcqodNMvfD4hjDkSOy6kb7k=";
        };
        "os-specific/linux/libs/wayland" = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wayland";
          repo = "wayland";
          rev = "8135e856ebd79872f886466e9cee39affb7d9ee8";
          sha256 = "sha256-nvNDONDdpoYNDD5q29IisvUY2lHsEcgJYGJUWbhpijs=";
        };
        "os-specific/linux/libs/wayland-protocols" = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wayland";
          repo = "wayland-protocols";
          rev = "e631010ab7b96988e7c64c24b7d90f64717eaeee";
          sha256 = "sha256-eS7nurCjYetDNQORYIVITE93JW4KUqJv/GBEoe/HUkw=";
        };
        "os-specific/linux/zig/zig-wayland" = fetchFromGitHub {
          owner = "ExpidusOS";
          repo = "zig-wayland";
          rev = "ba8cee50a8f761f0aef7922a2f0747c37ca428b1";
          sha256 = "sha256-Cotkqv5v1hJh3NBbi4I2dOFKZjG7kCdLttGf0L1f6Ew=";
        };
        "third-party/libs/expat" = fetchFromGitHub {
          owner = "libexpat";
          repo = "libexpat";
          rev = "654d2de0da85662fcc7644a7acd7c2dd2cfb21f0";
          sha256 = "sha256-nX8VSlqpX/SVE4fpPLOzj3s/D3zmTC9pObIYfkQq9RA=";
        };
        "third-party/libs/hwdata" = fetchFromGitHub {
          owner = "vcrhonek";
          repo = "hwdata";
          rev = "0e25d93ac6433791edbb9d28b3f8eae0cf5e46ff";
          sha256 = "sha256-+9UyF4tcy5cJPjbyQ2RuWVJkBsZut+YX2ncUJIqIQZo=";
        };
        "third-party/libs/libdisplay-info" = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "emersion";
          repo = "libdisplay-info";
          rev = "92b031749c0fe84ef5cdf895067b84a829920e25";
          sha256 = "sha256-7t1CoLus3rPba9paapM7+H3qpdsw7FlzJsSHFwM/2Lk=";
        };
        "third-party/libs/libffi" = fetchFromGitHub {
          owner = "libffi";
          repo = "libffi";
          rev = "f08493d249d2067c8b3207ba46693dd858f95db3";
          sha256 = "sha256-98WtmJLAdI6cpQAOBTCz7OyZl7um9XAzkRVL12NZ1mc=";
        };
        "third-party/zig/zig-clap" = fetchFromGitHub {
          owner = "Hejsil";
          repo = "zig-clap";
          rev = "cb13519431b916c05c6c783cb0ce3b232be5e400";
          sha256 = "sha256-ej4r5LGsTqhQkw490yqjiTOGk+jPMJfUH1b/eUmvt20=";
        };
      } // args'.vendorOverride;

      version = "git+${builtins.substring 0 7 args'.rev}${optionalString (branch != "master") "-${args'.branch}"}";
    in stdenv.mkDerivation {
      pname = "expidus-neutron";
      inherit version;
      inherit (args') src;

      outputs = [ "out" ]
        ++ optional (args'.enableDocs) "devdocs";

      nativeBuildInputs = [ args'.zig ];

      configurePhase = ''
        ${concatStrings (attrValues (mapAttrs (path: src: ''
          echo "Linking ${src} -> $NIX_BUILD_TOP/source/vendor/${path}"
          rm -rf $NIX_BUILD_TOP/source/vendor/${path}
          cp -r -P --no-preserve=ownership,mode ${src} $NIX_BUILD_TOP/source/vendor/${path}
        '') vendor))}
      '';

      buildFlags = [
        "-Dtarget=${args'.target}"
        "-Dflutter-engine=${flutter-engine.${args'.engineType}}/lib/flutter/out/${args'.engineType}"
        "-Dhost-dynamic-linker=${buildPackages.stdenv.cc.libc}/lib/ld-linux-${replaceStrings ["_"] ["-"] buildPlatform.parsed.cpu.name}.so.2"
      ] ++ optional (args'.target == "${targetPlatform.system}-gnu")
        "-Dtarget-dynamic-linker=${stdenv.cc.libc}/lib/ld-linux-${replaceStrings ["_"] ["-"] targetPlatform.parsed.cpu.name}.so.2";

      dontBuild = true;

      installPhase = ''
        export XDG_CACHE_HOME=$NIX_BUILD_TOP/.cache
        mkdir -p $out/lib

        zig build $buildFlags --prefix $out \
          --prefix-lib-dir $out/lib \
          --cache-dir $out/zig-cache

        if [[ -d $out/docs ]]; then
          rm -rf $devdocs/share/docs
          mkdir -p $devdocs/share/docs/
          mv $out/docs $devdocs/share/docs/neutron
        fi

        rm -rf $out/zig-cache/c
        rm -rf $out/zig-cache/h
        rm -rf $out/zig-cache/neutron
        rm -rf $out/zig-cache/tmp
        rm -rf $out/zig-cache/z
        rm -rf $out/zig-cache/zig-wayland
        find $out/zig-cache/o -type f -not -name '*.so*' -delete

        if [[ -f $out/bin/neutron-runner ]]; then
          source ${makeWrapper.outPath}/nix-support/setup-hook
          wrapProgram $out/bin/neutron-runner \
            --prefix LD_LIBRARY_PATH : "$out/lib"
        fi
      '';

      meta = {
        description = "Core API for ExpidusOS";
        homepage = "https://github.com/ExpidusOS/neutron";
        license = licenses.gpl3Only;
        maintainers = with maintainers; [ RossComputerGuy ];
      };
    };
in mkPackage
