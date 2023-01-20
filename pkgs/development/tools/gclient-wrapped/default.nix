{ writeShellScriptBin, python310, cipd, depot_tools }:
let
  python-pkg = python310.withPackages (p: with p; [ google-auth-httplib2 ]);
in writeShellScriptBin "gclient" ''
  export PATH=${cipd}/bin:${python-pkg}/bin:$PATH
  ${python-pkg}/bin/python ${depot_tools}/gclient.py "$@"
''
