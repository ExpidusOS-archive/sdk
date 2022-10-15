{ lib }:
rec {
  inherit (builtins)
    pathExists readFile isBool
    isInt isFloat add sub lessThan
    seq deepSeq genericClosure;

  release = lib.strings.fileContents ../.version;
  versionSuffix =
    let suffixFile = ../.version-suffix;
    in if pathExists suffixFile
    then "-${lib.strings.fileContents suffixFile}"
    else "";

  revision = let
    revisionFile = "${toString ./..}/.git-revision";
    gitRepo = "${toString ./..}/.git";
  in if lib.pathIsGitRepo gitRepo
    then lib.commitIdFromGitRepo gitRepo
    else if lib.pathExists revisionFile then lib.fileContents revisionFile
    else "unknown";

  revisionTag = if revision != "unknown" then "-${revision}" else "";

  version = release + versionSuffix + revisionTag;
  codeName = "Willamette";
}
