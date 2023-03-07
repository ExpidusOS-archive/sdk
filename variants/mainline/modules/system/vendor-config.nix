{ lib, config, options, ... }:
with lib;
let
  cfg = config.system.vendorConfig;
  opts = options.system.vendorConfig;
in
{
  options.system.vendorConfig = mkOption {
    type = with types; attrsOf (attrsOf (oneOf [ number str bool ]));
    description = mdDoc ''
      Vendor configuration
    '';
    default = {
      System = {
        nix_daemon = true;
        nix_store = true;
      };
      VendorConfig = {
        datafs = false;
      };
    };
  };

  config.environment.etc."expidus/vendor.conf" = {
    text = expidus.trivial.mkVendorConfig cfg;
    mode = "0777";
  };
}
