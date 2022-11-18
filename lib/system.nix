{ lib }:
let
  current = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else "x86_64-linux";
  isSupported = value: value == true;
  getSupportedList = list: builtins.map (system: system == current) list;
  checkSupport = list: (builtins.length (builtins.filter isSupported (getSupportedList list))) > 0;
in
rec {
  inherit current;

  linux = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];
  darwin = [ "aarch64-darwin" "x86_64-darwin" ];
  
  isDarwin = checkSupport darwin;
  isLinux = checkSupport linux;

  supported = linux ++ (if isDarwin then darwin else []);

  forAllLinux = lib.genAttrs linux;
  forAll = lib.genAttrs supported;
}
