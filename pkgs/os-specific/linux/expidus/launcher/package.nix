{ lib, stdenv, buildPackages, fetchFromGitHub, expidus, plymouth, check }:
with lib;
let
  mesonFeature = b: if b then "enabled" else "disabled";

  mkPackage = {
    rev,
    version ? "git+${rev}",
    branch ? "master",
    sha256 ? fakeHash,
    mesonFlags ? [],
    features ? {},
    src ? fetchFromGitHub {
      owner = "ExpidusOS";
      repo = "launcher";
      inherit rev sha256;
    }
  }:
  let
    featdefs = {
      tests = {
        default = check.meta.available;
        input = check;
      };
      plymouth = {
        default = plymouth.meta.available;
        input = plymouth;
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
    pname = "expidus-launcher";
    inherit version src;

    nativeBuildInputs = with buildPackages; [
      buildPackages.expidus.sdk
      meson
      ninja
      pkg-config
    ] ++ nativeFeatureInputs;

    buildInputs = [
      expidus.libvenfig
    ] ++ featureInputs;

    mesonFlags = mesonFlags ++ [
      "-Dgit-commit=${builtins.substring 0 7 rev}"
      "-Dgit-branch=${branch}"
    ] ++ featureFlags;

    postInstall = ''
      mkdir -p $out/bin
    '';

    passthru = {
      inherit mkPackage;
      features = features';
    };

    meta = {
      description = "Shell launcher for ExpidusOS";
      homepage = "https://github.com/ExpidusOS/launcher";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ RossComputerGuy ];
    };
  };
in mkPackage
