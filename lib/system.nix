{ lib }:
let
  host = builtins.filter builtins.isString (builtins.split "-" (builtins.getEnv "EXPIDUS_SDK_HOST"));
  currentBultin = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else null;
  currentEnv =
    if builtins.length host == 3 then
      "${builtins.elemAt host 0}-${builtins.elemAt host 1}"
    else null;

  current = if currentEnv == null then (if currentBultin == null then "x86_64-linux" else currentBultin) else currentEnv;

  makeSystemSet = systems:
    let
      systemFilter = name: builtins.filter (str:
        let
          system = lib.systems.parse.mkSystemFromString str;
        in system.kernel.name == name) systems;
    in {
      linux = systemFilter "linux";
      darwin = systemFilter "darwin";
      cygwin = systemFilter "windows";
    };

  makeSupported = {
    cygwin ? lib.platforms.cygwin,
    linux ? lib.platforms.linux,
    darwin ? builtins.map (name: "${name}-darwin") [ "aarch64" "x86_64" ]
  }@args: ({
    cygwin = lib.platforms.cygwin;
    linux = lib.platforms.linux;
    darwin = builtins.map (name: "${name}-darwin") [ "aarch64" "x86_64" ];
  } // args);

  make = {
    currentSystem ? current,
    supported ? makeSupported {}
  }:
    let
      getSupported = system: list: builtins.map (value: value == system) list;
      isSupported = system: list: (builtins.length (builtins.filter (value: value == true) (getSupported system list))) > 0;
      isToplevel = currentSystem == current;
      _supported = makeSupported (if builtins.isList supported then makeSystemSet supported else supported);
    in (rec {
      inherit isToplevel make makeSupported;

      current = currentSystem;
      isCygwin = isSupported currentSystem _supported.cygwin;
      isDarwin = isSupported currentSystem _supported.darwin;
      isLinux = isSupported currentSystem _supported.linux;

      supported = _supported.linux ++ _supported.cygwin ++ (if isDarwin then _supported.darwin else []);

      forAllCygwin = lib.genAttrs _supported.cygwin;
      forAllDarwin = lib.genAttrs _supported.darwin;
      forAllLinux = lib.genAttrs _supported.linux;
      forAll = lib.genAttrs (_supported.linux ++ _supported.cygwin ++ (if isDarwin then _supported.darwin else []));
    }) // (if isToplevel then {
      inherit getSupported isSupported;
    } else {
      getSupported = getSupported currentSystem;
      isSupported = isSupported currentSystem;

      parent = make current;
    });
in make {}
