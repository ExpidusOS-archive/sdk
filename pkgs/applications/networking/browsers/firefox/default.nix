{ lib, stdenv, writeText, makeWrapper, wrapFirefox, firefox-unwrapped, firefox-esr-102-unwrapped }:
let
  makeFiles = { applicationName }: rec {
  };

  override = drv: {
    binaryName ? "firefox",
    application ? "browser",
    applicationName ? "Mozilla Firefox",
    ...
  }@args:
    let
      distributionIni = writeText "distribution.ini" (lib.generators.toINI {} {
        Global = {
          id = "expidus";
          inherit (lib.expidus.trivial) version;
          about = "${applicationName} for ExpidusOS";
        };
        Preferences = {
          "app.distributor" = "expidus";
          "app.distributor.channel" = "expidus-sdk";
          "app.partner.expidus" = "expidus";
        };
      });
      
      defaultPrefs = {
        "geo.provider.network.url" = {
          value = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
          reason = "Use MLS by default for geolocation, since our Google API Keys are not working";
        };
      };

      defaultPrefsFile = writeText "expidus-default-prefs.js" (lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value: ''
        // ${value.reason}
        pref("${key}", ${builtins.toJSON value.value});
      '') defaultPrefs));
    in stdenv.mkDerivation {
      inherit (drv) name version passthru meta;

      installPhase = ''
        cp -r ${drv.outPath}/bin $out/bin
        cp -r ${drv.outPath}/lib $out/lib
        cp -r ${drv.outPath}/share $out/share
        install -Dvm644 ${distributionIni} $out/lib/${binaryName}/distribution/distribution.init
        install -Dvm644 ${defaultPrefsFile} $out/lib/${binaryName}/browser/defaults/preferences/expidus-default-prefs.js
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        "$out/bin/${binaryName}" --version
      '';
    };
in {
  firefox = override firefox-unwrapped {};
  firefox-esr-102 = override firefox-esr-102-unwrapped { applicationName = "Mozilla Firefox ESR"; };
}
