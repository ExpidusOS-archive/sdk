{ lib, fetchFromGitHub, stdenv, buildPackages, check, flutter-engine, libglvnd, pixman, xorg, wlroots, wayland, libxkbcommon, systemd }@pkgs:
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
    bootstrap ? false,
    mesonFlags ? [],
    passthru ? {},
    engineType ? "release",
    buildType ? "release",
    sha256 ? fakeHash,
    vendorHash ? fakeHash
  }@args:
    stdenv.mkDerivation {
      pname = "neutron${optionalString bootstrap "-bootstrap"}";
      version = "git+${builtins.substring 0 7 rev}";

      inherit src;

      outputs = [ "out" "dev" "devdoc" ];

      nativeBuildInputs = with buildPackages; [
        expidus.sdk
        meson
        ninja
        pkg-config
        gtk-doc
        libxslt
        docbook_xsl
        docbook_xml_dtd_412
        docbook_xml_dtd_42
        docbook_xml_dtd_43
      ] ++ optionals (!bootstrap) [
        flutter.dart
        flutter
      ] ++ optionals (wayland.meta.available && !bootstrap) [
        wayland-protocols
      ];

      preConfigure = ''
        export HOME=$NIX_BUILD_TOP
      '';

      buildInputs = optionalPkg libglvnd
        ++ optionalPkg pixman
        ++ optionalPkg xorg.libxcb
        ++ optionalPkg wlroots
        ++ optionalPkg wayland
        ++ optional (xorg.libxcb.meta.available || wayland.meta.available) libxkbcommon
        ++ optional (stdenv.isLinux) systemd
        ++ optionalPkg check;
      doCheck = check.meta.available;

      mesonBuildType = buildType;
      mesonFlags = mesonFlags ++ [
        "-Dgit-commit=${builtins.substring 0 7 rev}"
        "-Dgit-branch=${branch}"
        "-Dbootstrap=${if bootstrap then "true" else "false"}"
        "-Dflutter-engine=${flutter-engine}/lib/flutter/out/${engineType}"
        "-Dtests=${mesonFeature check.meta.available}"
        "-Ddocs=${mesonFeature buildPackages.gtk-doc.meta.available}"
        "-Ddisplaykit-compositor-xcb=${mesonFeature xorg.libxcb.meta.available}"
        "-Ddisplaykit-compositor-wlroots=${mesonFeature wlroots.meta.available}"
        "-Ddisplaykit-client-xcb=${mesonFeature xorg.libxcb.meta.available}"
        "-Dgraphics-renderer-egl=${mesonFeature libglvnd.meta.available}"
        "-Dgraphics-renderer-pixman=${mesonFeature pixman.meta.available}"
      ];

      postInstall = ''
        mkdir -p $dev/lib
        mv $out/lib/neutron $dev/lib/neutron
      '';

      passthru = passthru // {
        inherit mkPackage rev branch;
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
