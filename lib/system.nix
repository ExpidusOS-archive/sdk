{ lib, expidus }:
let
  host = builtins.filter builtins.isString (builtins.split "-" (builtins.getEnv "EXPIDUS_SDK_HOST"));
  currentBultin = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else null;
  currentActivationSystem = if builtins.pathExists "/run/current-system/system" then (builtins.readFile "/run/current-system/system") else "x86_64-linux";
  currentEnv =
    if builtins.length host == 3 then
      "${builtins.elemAt host 0}-${builtins.elemAt host 1}"
    else null;

  current = if currentEnv == null then (if currentBultin == null then currentActivationSystem else currentBultin) else currentEnv;

  libPlatforms = import "${expidus.channels.nixpkgs}/lib/systems/platforms.nix" { inherit lib; };

  mapSystemToAttrs = builtins.map (system: {
    name = system;
    value = {
      inherit system;
    };
  });

  defaultCygwin = [];
  defaultDarwin = mapSystemToAttrs (builtins.map (name: "${name}-darwin") [ "aarch64" "x86_64" ]);
  defaultLinux =
    (mapSystemToAttrs (lib.lists.subtractLists [
      "aarch64-linux"
      "armv5tel-linux"
      "armv7a-linux"
      "m68k-linux"
      "microblaze-linux"
      "microblazeel-linux"
      "mipsel-linux"
      "mips64el-linux"
      "powerpc64le-linux"
      "powerpc64-linux"
      "riscv32-linux"
      "riscv64-linux"
      "s390-linux"
      "s390x-linux"
    ] lib.platforms.linux) ++ [
      {
        name = "raspberry-pi";
        value = {
          config = "armv6l-unknown-linux-gnueabihf";
          system = "armv6l-linux";
        } // libPlatforms.raspberrypi;
      }
      {
        name = "aarch64-multiplatform";
        value = {
          config = "aarch64-unknown-linux-gnu";
          system = "aarch64-linux";
        };
      }
      {
        name = "powerpc64le-linux";
        value = {
          config = "powerpc64le-unknown-linux-gnuabielfv2";
          system = "powerpc64le-linux";
        };
      }
      {
        name = "aarch64-linux";
        value = {
          config = "aarch64-unknown-linux-gnu";
          system = "aarch64-linux";
        };
      }
      {
        name = "riscv64-linux";
        value = {
          config = "riscv64-unknown-linux-gnu";
          system = "riscv64-linux";
        };
      }
    ]);
  defaultExtra = [
    {
      name = "wasi32";
      value = {
        config = "wasm32-unknown-wasi";
        useLLVM = true;
        system = "wasm32-wasi";
      };
    }
    {
      name = "wasi64";
      value = {
        config = "wasm64-unknown-wasi";
        useLLVM = true;
        system = "wasm64-wasi";
      };
    }
  ];

  makeSystemSet = systems:
    let
      systemFilter = name: builtins.filter (str:
        let
          system = lib.systems.parse.mkSystemFromString str.value.system;
        in system.kernel.name == name) systems;
    in {
      linux = systemFilter "linux";
      darwin = systemFilter "darwin";
      cygwin = systemFilter "windows";
    };

  makeSupported = {
    cygwin ? defaultCygwin,
    linux ? defaultLinux,
    darwin ? defaultDarwin,
    extra ? defaultExtra
  }@args: ({
    cygwin = defaultCygwin;
    linux = defaultLinux;
    darwin = defaultDarwin;
    extra = defaultExtra;
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
      extraSupported = builtins.map (nv: nv.name) _supported.extra;
      supportedList = _supported.linux ++ _supported.cygwin ++ (if canDarwin then _supported.darwin else []) ++ _supported.extra;
      possibleList = _supported.linux ++ _supported.cygwin ++ _supported.darwin ++ _supported.extra;

      genAttrs = list: func: builtins.listToAttrs (builtins.map ({ name, value }: {
        inherit name;
        value = func name;
      }) list);

      genAttrs' = list: func: builtins.listToAttrs (builtins.map ({ name, value }: {
        name = value.system;
        value = func name;
      }) list);

      supportedSystems = builtins.listToAttrs supportedList;
      possibleSystems = builtins.listToAttrs possibleList;
    in (rec {
      inherit isToplevel isDarwin canDarwin makeSupported make supportedSystems possibleSystems _supported;

      current = currentSystem;
      isCygwin = isSupported currentSystem _supported.cygwin;
      isLinux = isSupported currentSystem _supported.linux;

      supported = supportedList;
      possible = possibleList;

      mapSupported = func: builtins.mapAttrs func supportedSystems;
      mapPossible = func: builtins.mapAttrs func possibleSystems;
      mapSupportedSystems = genAttrs' supportedList;
      mapPossibleSystems = genAttrs' possibleList;

      linuxMatrix = builtins.map ({ a, b }: "${a.system}/${b.system}") (lib.cartesianProductOfSets { a = _supported.linux; b = _supported.linux; });

      mapLinuxMatrix = func:
        let
          doMap = lib.genAttrs linuxMatrix;
        in builtins.mapAttrs (_: func) (doMap (str: {
          host = lib.lists.head (lib.splitString "/" str);
          target = lib.lists.head (lib.lists.tail (lib.splitString "/" str));
        }));

      forAllCygwin = genAttrs _supported.cygwin;
      forAllDarwin = genAttrs _supported.darwin;
      forAllLinux = genAttrs _supported.linux;
      forAll = genAttrs supportedList;
      forAllPossible = genAttrs possibleList;
    }) // (if isToplevel then {
      inherit getSupported isSupported;

      defaultSupported = {
        darwin = defaultDarwin;
        cygwin = defaultCygwin;
        linux = defaultLinux;
        extra = defaultExtra;
      };
    } else {
      getSupported = getSupported currentSystem;
      isSupported = isSupported currentSystem;

      parent = make current;
    });
in make {}
