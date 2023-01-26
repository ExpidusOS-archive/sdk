{ lib }:
with lib;
fixedPoints.makeExtensible (self: rec {
  release = strings.fileContents ../.version;

  versionSuffix = (let suffixFile = ../.version-suffix;
      in if builtins.pathExists suffixFile
      then "-${strings.fileContents suffixFile}"
      else "-alpha");

  revisionWithDefault = (default:
      let
        revisionFile = "${toString ./..}/.git-revision";
        gitRepo      = "${toString ./..}/.git";
      in if pathIsGitRepo gitRepo
        then commitIdFromGitRepo gitRepo
        else if pathExists revisionFile then fileContents revisionFile
        else default);

  revision = self.revisionWithDefault "unknown";
  revisionTag = if self.revision != "unknown" then ".${self.revision}" else "";

  version = self.release + self.versionSuffix + self.revisionTag;
  codeName = self.codeName or "Willamette";
})
