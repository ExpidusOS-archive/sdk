{ lib }:
let
  host = builtins.filter builtins.isString (builtins.split "-" (builtins.getEnv "EXPIDUS_SDK_HOST"));
  currentBultin = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else null;
  currentEnv =
    if builtins.length host == 3 then
      "${builtins.elemAt host 0}-${builtins.elemAt host 1}"
    else null;

  current = if currentEnv == null then (if currentBultin == null then "x86_64-linux" else currentBultin) else currentEnv;

  make = currentSystem:
    let
      getSupported = system: list: builtins.map (value: value == system) list;
      isSupported = system: list: (builtins.length (builtins.filter (value: value == true) (getSupported system list))) > 0;
      isToplevel = currentSystem == current;
    in (rec {
      inherit isToplevel make;
      inherit (lib.platforms) cygwin linux;

      current = currentSystem;
      darwin = builtins.map (name: "${name}-darwin") [ "aarch64" "x86_64" ];

      isCygwin = isSupported currentSystem cygwin;
      isDarwin = isSupported currentSystem darwin;
      isLinux = isSupported currentSystem linux;

      supported = linux ++ cygwin ++ (if isDarwin then darwin else []);

      forAllCygwin = lib.genAttrs cygwin;
      forAllDarwin = lib.genAttrs darwin;
      forAllLinux = lib.genAttrs linux;
      forAll = lib.genAttrs supported;
    }) // (if isToplevel then {
      inherit getSupported isSupported;
    } else {
      getSupported = getSupported currentSystem;
      isSupported = isSupported currentSystem;

      parent = make current;
    });
in make current
