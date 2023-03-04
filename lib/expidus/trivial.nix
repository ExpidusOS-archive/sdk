{ lib }:
with lib;
fixedPoints.makeExtensible (self: rec {
  release = strings.fileContents ../../.version;

  versionSuffix = (let suffixFile = ../../.version-suffix;
      in if builtins.pathExists suffixFile
      then "-${strings.fileContents suffixFile}"
      else "-alpha");

  revisionWithDefault = (default:
      let
        revisionFile = "${toString ./../..}/.git-revision";
        gitRepo      = "${toString ./../..}/.git";
      in if pathIsGitRepo gitRepo
        then commitIdFromGitRepo gitRepo
        else if pathExists revisionFile then fileContents revisionFile
        else default);

  revision = self.revisionWithDefault "unknown";
  revisionTag = if self.revision != "unknown" then ".${self.revision}" else "";

  version = self.release + self.versionSuffix + self.revisionTag;
  codename = "Willamette";

  mkVendorConfig = vendorConfig:
    let
      stringify = value:
        if isString value then value
        else if isInt value then toString value
        else if isBool value then (if value then "true" else "false")
        else if isList value then concatMapStringsSep "," stringify value
        else throw "Unsupported type";

      listOfAttrs = attrValues (mapAttrs (topLevel: children:
        attrsets.renameAttrs
          (key: value: "${topLevel}::${key}") children) vendorConfig);

      flat = lists.flatten (map (configs: attrValues (mapAttrs (key: value: "${key}=${stringify value}") configs)) listOfAttrs);
    in concatStringsSep "\n" flat;
})
