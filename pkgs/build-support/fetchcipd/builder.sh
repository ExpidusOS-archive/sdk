source $stdenv/setup

cipd ensure -root $NIX_BUILD_TOP -ensure-file $ensureFile
mkdir -p $out
cp -r $(readlink -e $NIX_BUILD_TOP/src)/* $out
