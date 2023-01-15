{ lib }:
with lib;
fixedPoints.makeExtensible (self: rec {
  release = self.release or strings.fileContents ../.version;

  versionSuffix = self.versionSuffix or
    (let suffixFile = ../.version-suffix;
      in if builtins.pathExists suffixFile
      then "-${strings.fileContents suffixFile}"
      else "-alpha");

  revisionWithDefault = self.revisionWithDefault or
    (default:
      let
        revisionFile = "${toString ./..}/.git-revision";
        gitRepo      = "${toString ./..}/.git";
      in if pathIsGitRepo gitRepo
        then commitIdFromGitRepo gitRepo
        else if pathExists revisionFile then fileContents revisionFile
        else default);

  revision = self.revision or (revisionWithDefault "unknown");
  revisionTag = self.revisionTag or (if revision != "unknown" then ".${revision}" else "");

  version = self.version or (release + versionSuffix + revisionTag);
  codeName = self.codeName or "Willamette";
})
