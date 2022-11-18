{ lib }:
let
  host = builtins.filter builtins.isString (builtins.split "-" (builtins.getEnv "EXPIDUS_SDK_HOST"));
  currentBultin = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else null;
  currentEnv =
    if builtins.length host == 3 then
      "${builtins.elemAt host 0}-${builtins.elemAt host 1}"
    else null;

  current = if currentEnv == null then (if currentBultin == null then "x86_64-linux" else currentBultin) else currentEnv;
  isSupported = value: value == true;
  getSupportedList = list: builtins.map (system: system == current) list;
  checkSupport = list: (builtins.length (builtins.filter isSupported (getSupportedList list))) > 0;
in
rec {
  inherit current currentBultin currentEnv;

  linux = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];
  darwin = [ "aarch64-darwin" "x86_64-darwin" ];
  
  isDarwin = checkSupport darwin;
  isLinux = checkSupport linux;

  supported = linux ++ (if isDarwin then darwin else []);

  forAllLinux = lib.genAttrs linux;
  forAll = lib.genAttrs supported;
}
