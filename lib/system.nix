{ lib, expidus }:
let
  host = builtins.filter builtins.isString (builtins.split "-" (builtins.getEnv "EXPIDUS_SDK_HOST"));
  currentBultin = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else null;
  currentEnv =
    if builtins.length host == 3 then
      "${builtins.elemAt host 0}-${builtins.elemAt host 1}"
    else null;

  current = if currentEnv == null then (if currentBultin == null then "x86_64-linux" else currentBultin) else currentEnv;

  defaultCygwin = lib.platforms.cygwin;
  defaultDarwin = builtins.map (name: "${name}-darwin") [ "aarch64" "x86_64" ];
  defaultLinux = lib.lists.subtractLists [
    "s390x-linux"
    "s390-linux"
    "riscv32-linux"
    "powerpc64-linux"
    "mips64el-linux"
    "mipsel-linux"
    "microblazeel-linux"
    "microblaze-linux"
    "m68k-linux"
    "armv7a-linux"
    "armv5tel-linux"
  ] lib.platforms.linux;

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
    cygwin ? defaultCygwin,
    linux ? defaultLinux,
    darwin ? defaultDarwin
  }@args: ({
    cygwin = defaultCygwin;
    linux = defaultLinux;
    darwin = defaultDarwin;
  } // args);

  /*
    Makes a new system support attribute set
  */
  make = {
    currentSystem ? current,
    supported ? makeSupported {},
    allowDarwin ? false
  }@args:
    let
      getSupported = system: list: builtins.map (value: value == system) list;
      isSupported = system: list: (builtins.length (builtins.filter (value: value == true) (getSupported system list))) > 0;
      isToplevel = currentSystem == current;
      _supported = makeSupported (if builtins.isList supported then makeSystemSet supported else supported);

      isDarwin = isSupported currentSystem _supported.darwin;
      canDarwin = isDarwin || allowDarwin;
      supportedList = _supported.linux ++ _supported.cygwin ++ (if canDarwin then _supported.darwin else []);
      possibleList = _supported.linux ++ _supported.cygwin ++ _supported.darwin;
    in (rec {
      inherit isToplevel makeSupported make;

      current = currentSystem;
      isCygwin = isSupported currentSystem _supported.cygwin;
      isLinux = isSupported currentSystem _supported.linux;
      inherit isDarwin canDarwin;

      supported = supportedList;
      possible = possibleList;

      forAllCygwin = lib.genAttrs _supported.cygwin;
      forAllDarwin = lib.genAttrs _supported.darwin;
      forAllLinux = lib.genAttrs _supported.linux;
      forAll = lib.genAttrs supportedList;
      forAllPossible = lib.genAttrs possibleList;
    }) // (if isToplevel then {
      inherit getSupported isSupported;

      defaultSupported = {
        darwin = defaultDarwin;
        cygwin = defaultCygwin;
        linux = defaultLinux;
      };
    } else {
      getSupported = getSupported currentSystem;
      isSupported = isSupported currentSystem;

      parent = make current;
    });
in make {}
