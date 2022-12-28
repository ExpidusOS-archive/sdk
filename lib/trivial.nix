{ lib }:
let
  /*
    Creates a new version
  */
  makeVersion = self:
    let
      trivial = if self == null then {} else self;
    in rec {
      release = trivial.release or lib.strings.fileContents ../.version;

      versionSuffix = trivial.versionSuffix or
        (let suffixFile = ../.version-suffix;
          in if builtins.pathExists suffixFile
          then "-${lib.strings.fileContents suffixFile}"
          else "-alpha");

      revisionWithDefault = trivial.revisionWithDefault or
        (default:
          let
            revisionFile = "${toString ./..}/.git-revision";
            gitRepo      = "${toString ./..}/.git";
          in if lib.pathIsGitRepo gitRepo
           then lib.commitIdFromGitRepo gitRepo
           else if lib.pathExists revisionFile then lib.fileContents revisionFile
           else default);

      revision = trivial.revision or (revisionWithDefault "unknown");
      revisionTag = trivial.revisionTag or (if revision != "unknown" then ".${revision}" else "");

      version = trivial.version or (release + versionSuffix + revisionTag);
      codeName = trivial.codeName or "Willamette";
    };
in ({
  inherit makeVersion;
}) // makeVersion null
