{ lib, stdenv, fetchFromGitHub, buildPackages, expidus, check }:
with lib;
let
  mesonFeature = b: if b then "enabled" else "disabled";

  mkPackage = {
    rev,
    version ? "git+${builtins.substring 0 7 rev}",
    branch ? "master",
    buildType ? "release",
    sha256 ? fakeHash,
    mesonFlags ? [],
    features ? {},
    src ? fetchFromGitHub {
      owner = "ExpidusOS";
      repo = "libvenfig";
      inherit rev sha256;
    }
  }:
  let
    featdefs = {
      docs = {
        default = buildPackages.gtk-doc.meta.available;
        nativeInputs = with buildPackages; [
          gtk-doc
          libxslt
          docbook_xsl
          docbook_xml_dtd_412
          docbook_xml_dtd_42
          docbook_xml_dtd_43
        ];
      };
      tests = {
        default = check.meta.available;
        input = check;
      };
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
    pname = "libvenfig";
    inherit version src;

    outputs = [ "out" "dev" ] ++
      optional (features'.docs.value) "devdoc";

    nativeBuildInputs = with buildPackages; [
      buildPackages.expidus.sdk
      meson
      ninja
      pkg-config
    ] ++ nativeFeatureInputs;

    buildInputs = featureInputs ++ [
      expidus.neutron
    ];

    propagatedBuildInputs = featureInputs ++ [
      expidus.neutron
    ];

    mesonBuildType = buildType;
    mesonFlags = mesonFlags ++ [
      "-Dgit-commit=${builtins.substring 0 7 rev}"
      "-Dgit-branch=${branch}"
      "--sysconfdir=/etc"
    ] ++ featureFlags;

    doCheck = features'.tests.value;

    passthru = {
      inherit mkPackage;
      features = features';
    };

    meta = {
      description = "Library for handling ExpidusOS's vendor configuration.";
      homepage = "https://github.com/ExpidusOS/libvenfig";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ RossComputerGuy ];
    };
  };
in mkPackage
