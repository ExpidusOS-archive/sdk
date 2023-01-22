source $stdenv/setup

cipd ensure -root $NIX_BUILD_TOP -ensure-file $ensureFile
cp -r $(readlink -e $NIX_BUILD_TOP/src/*) $out
