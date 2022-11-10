{ system ? builtins.currentSystem, configuration ? (import ./lib/from-env.nix {}) "NIXOS_CONFIG" <nixos-config> }:
let
  eval = import ./lib/eval-config.nix {
    inherit system;
    pkgs = import ../pkgs/default.nix { inherit system; };
    lib = import ../lib/;
    modules = [ configuration ];
  };
in
{
  inherit (eval) pkgs config options;
  system = eval.config.system.build.toplevel;
  inherit (eval.config.system.build) vm vmWithBootLoader;
}
