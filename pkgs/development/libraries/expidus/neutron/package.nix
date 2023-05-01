{ lib,
  buildFHSUserEnv,
  fetchFromGitHub,
  writeShellScriptBin,
  makeWrapper,
  stdenv,
  buildPlatform,
  buildPackages,
  targetPlatform,
  wayland,
  wayland-protocols,
  wlroots,
  pixman,
  libxkbcommon,
  libdrm,
  mesa,
  libglvnd,
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
        buildType = "ReleaseFast";
        sha256 = fakeHash;
        target = "${targetPlatform.system}-gnu";
      } // args;

      vendor = {
        "bindings/vulkan-zig" = fetchFromGitHub {
          owner = "Snektron";
          repo = "vulkan-zig";
          rev = "02939ff0266678643e8f32ea430bbef3335705b8";
          sha256 = "sha256-QapGlkgPNhIqniYemcCNCJtNogT83Rn+IoUVqC1Jtto=";
        };
        "bindings/zig-flutter" = fetchFromGitHub {
          owner = "ExpidusOS";
          repo = "zig-flutter";
          rev = "256de1bf11ba5ea20740a575a1b1e078e547abad";
          fetchSubmodules = true;
          sha256 = "sha256-JHmwuBl1qFrihRSONK5wYbd+jQJJQxQEB0ZwpCQzNp8=";
        };
        "bindings/zig-pixman" = fetchFromGitHub {
          owner = "ifreund";
          repo = "zig-pixman";
          rev = "4a49ba13eb9ebb0c0f991de924328e3d615bf283";
          sha256 = "sha256-2iuK2DVu5w29eDHnlVyWt4d6as6gjVqhg+1/TxRmkZ8=";
        };
        "bindings/zig-wayland" = fetchFromGitHub {
          owner = "ExpidusOS";
          repo = "zig-wayland";
          rev = "95e8afad008b5c443f6420dde46e92a5709a3481";
          sha256 = "sha256-Boq1OqGBcDvfhTCdk7eWKrNVfcPCBS7QOt0ETJYZMFo=";
        };
        "bindings/zig-wlroots" = fetchFromGitHub {
          owner = "swaywm";
          repo = "zig-wlroots";
          rev = "c4cdb08505de19f6bfbf8e1825349b80c7696475";
          sha256 = "sha256-1m5QBroCOOFmoP51S2zZafNhUFWiwr20ETiKCp5uKHc=";
        };
        "bindings/zig-xkbcommon" = fetchFromGitHub {
          owner = "ifreund";
          repo = "zig-xkbcommon";
          rev = "bfd1f97c277c32fddb77dee45979d2f472595d19";
          sha256 = "sha256-2fEMbN86alYN6JLRVL/0dbgp/Qo5M3uXKc5RGIUGGC4=";
        };
        "third-party/zig/libxev" = fetchFromGitHub {
          owner = "mitchellh";
          repo = "libxev";
          rev = "e7d4e6dfd208b4d90715766f92aeaf0163e4bdd9";
          sha256 = "sha256-CPeuKZxJhRFuqjwQWfO0K0Q7umGi2wozznSQR4RwjOk=";
        };
        "third-party/zig/s2s" = fetchFromGitHub {
          owner = "ziglibs";
          repo = "s2s";
          rev = "b39cb2a75eb4b695f36dfbb8ee26bc5688987399";
          sha256 = "sha256-oY0QDpCZ8iG+v7F7p0oTrXF69/QjTAdphH7f4XQ9mvw=";
        };
        "third-party/zig/zig-clap" = fetchFromGitHub {
          owner = "Hejsil";
          repo = "zig-clap";
          rev = "ab69ef2db44b6c4b7f00283d52d38fbe71d16c42";
          sha256 = "sha256-wQAN6IRKp3l4oSw2qhvsqzsK+gjF0W+QDiGbq9PB530=";
        };
      } // args'.vendorOverride;

      version = "git+${builtins.substring 0 7 args'.rev}${optionalString (branch != "master") "-${args'.branch}"}";

      buildInputs = [
        wayland
        wayland-protocols
        wlroots
        pixman
        libxkbcommon
        libdrm
        mesa
        mesa.osmesa
        libglvnd
      ];

      zig-wrapped = writeShellScriptBin "expidus-neutron-zig" ''
        export PKG_CONFIG_PATH=${concatMapStringsSep ":" (pkg: (concatMapStringsSep ":" (output: concatMapStringsSep ":" (path: "${pkg.${output}.outPath}${path}") [ "/lib/pkgconfig" "/share/pkgconfig" ]) pkg.outputs)) buildInputs}
        exec ${zig}/bin/zig $@
      '';

      fhsEnv = buildFHSUserEnv {
        name = "expidus-neutron";

        targetPkgs = pkgs:
          (with buildPackages; [
            zig
            ninja
            zlib
            git
            curl
            pkg-config
          ]);

        runScript = "${zig-wrapped}/bin/${zig-wrapped.name}";
      };
    in stdenv.mkDerivation {
      pname = "expidus-neutron";
      inherit version buildInputs;
      inherit (args') src;

      outputs = [ "out" ]
        ++ optional (args'.enableDocs) "devdocs";

      strictDeps = true;
      depsBuildBuild = [ buildPackages.pkg-config ];

      nativeBuildInputs = with buildPackages; [
        wayland-scanner
        pkg-config
      ];

      configurePhase = ''
        ${concatStrings (attrValues (mapAttrs (path: src: ''
          echo "Linking ${src} -> $NIX_BUILD_TOP/source/vendor/${path}"
          rm -rf $NIX_BUILD_TOP/source/vendor/${path}
          cp -r -P --no-preserve=ownership,mode ${src} $NIX_BUILD_TOP/source/vendor/${path}
        '') vendor))}
      '';

      buildFlags = [
        "-Dtarget=${args'.target}"
      ];

      dontBuild = true;

      installPhase = ''
        export XDG_CACHE_HOME=$NIX_BUILD_TOP/.cache
        mkdir -p $out/lib

        ${fhsEnv}/bin/${fhsEnv.name} build $buildFlags --prefix $out \
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

        if [[ -f $out/bin/neutron ]]; then
          source ${makeWrapper.outPath}/nix-support/setup-hook
          wrapProgram $out/bin/neutron \
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
