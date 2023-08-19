{ config, pkgs, ... }:
{
  config.system.build.diskArchive = pkgs.runCommand "expidus-${config.system.expidus.label}-disk-archive.tar.xz" {} ''
    mkdir -p $NIX_BUILD_TOP/source
    cd $NIX_BUILD_TOP/source

    cp ${config.system.build.rootfs} $NIX_BUILD_TOP/source/rootfs.img
    cp ${config.system.build.datafs} $NIX_BUILD_TOP/source/datafs.img
    cp ${config.system.build.efipart} $NIX_BUILD_TOP/source/efipart.img

    tar cfJ $out .
  '';
}
