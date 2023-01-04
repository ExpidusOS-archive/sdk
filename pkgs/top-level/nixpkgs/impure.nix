let
  homeDir = builtins.getEnv "HOME";
  try = x: def: let res = builtins.tryEval x; in if res.success then res.value else def;
in
{ localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  config ? let
      configFile = builtins.getEnv "NIXPKGS_CONFIG";
      configFile2 = homeDir + "/.config/nixpkgs/config.nix";
      configFile3 = homeDir + "/.nixpkgs/config.nix"; # obsolete
    in
      if configFile != "" && builtins.pathExists configFile then import configFile
      else if homeDir != "" && builtins.pathExists configFile2 then import configFile2
      else if homeDir != "" && builtins.pathExists configFile3 then import configFile3
      else {},
  overlays ? let
      isDir = path: builtins.pathExists (path + "/.");
      pathOverlays = try (toString <nixpkgs-overlays>) "";
      homeOverlaysFile = homeDir + "/.config/nixpkgs/overlays.nix";
      homeOverlaysDir = homeDir + "/.config/nixpkgs/overlays";
      overlays = path:
        # check if the path is a directory or a file
        if isDir path then
          # it's a directory, so the set of overlays from the directory, ordered lexicographically
          let content = builtins.readDir path; in
          map (n: import (path + ("/" + n)))
            (builtins.filter
              (n:
                (builtins.match ".*\\.nix" n != null &&
                 # ignore Emacs lock files (.#foo.nix)
                 builtins.match "\\.#.*" n == null) ||
                builtins.pathExists (path + ("/" + n + "/default.nix")))
              (builtins.attrNames content))
        else
          # it's a file, so the result is the contents of the file itself
          import path;
    in
      if pathOverlays != "" && builtins.pathExists pathOverlays then overlays pathOverlays
      else if builtins.pathExists homeOverlaysFile && builtins.pathExists homeOverlaysDir then
        throw ''
          Nixpkgs overlays can be specified with ${homeOverlaysFile} or ${homeOverlaysDir}, but not both.
          Please remove one of them and try again.
        ''
      else if builtins.pathExists homeOverlaysFile then
        if isDir homeOverlaysFile then
          throw (homeOverlaysFile + " should be a file")
        else overlays homeOverlaysFile
      else if builtins.pathExists homeOverlaysDir then
        if !(isDir homeOverlaysDir) then
          throw (homeOverlaysDir + " should be a directory")
        else overlays homeOverlaysDir
      else [],
  crossOverlays ? [],
  ...
}@args:
assert args ? localSystem -> !(args ? system);
assert args ? system -> !(args ? localSystem);
import ./. (builtins.removeAttrs args [ "system" ] // {
  inherit config overlays localSystem;
})
