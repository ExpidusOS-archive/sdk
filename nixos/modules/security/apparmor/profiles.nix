{ config, lib, pkgs, ... }:
let
  inherit (builtins) attrNames hasAttr isAttrs;
  inherit (lib) getLib concatMapStringsSep;
  inherit (config.environment) etc;

  etcRule = arg:
    let go = { path ? null, mode ? "r", trail ? "" }:
      if (hasAttr path etc) then "${mode} ${config.environment.etc.${path}.source}${trail},"
      else "${mode} /etc/${path}${trail},";
    in if isAttrs arg
    then go arg
    else go { path = arg; };

  makeAppArmorRulesFromClosure = name: inputs: pkgs.apparmorRulesFromClosure { inherit name; } inputs;
  makePolicy = name: text: {
    ${name}.profile = lib.mkIf config.security.apparmor.policies.${name}.enable text;
  };

  makeCommandProfile = { name, pkg ? pkgs.${name}, command ? "${pkg}/bin/${name}", buildInputs ? pkg.buildInputs, extraInputs ? [], profile, flags ? [] }: ''
    include <tunables/global>

    profile ${name} ${command} ${if builtins.length flags > 0 then "flags=(${concatMapStringsSep "," (value: value) flags})" else ""} {
      include <abstractions/base>
      include "${makeAppArmorRulesFromClosure name (buildInputs ++ extraInputs)}"
      ${profile}
    }
  '';

  makeCommandPolicy = { enable ? true, name, profileName ? "bin.${name}", pkg ? pkgs.${name}, command ? "${pkg}/bin/${name}", buildInputs ? pkg.buildInputs, extraInputs ? [], profile, flags ? [] }: {
    ${profileName} = {
      inherit enable;
      profile = lib.mkIf config.security.apparmor.policies.${profileName}.enable (makeCommandProfile {
        inherit name pkg command buildInputs extraInputs profile flags;
      });
    };
  };

  policies =
    {
      "pam_roles".profile = ''
        include <tunables/global>

        profile default_user {
          include <abstractions/base>
          include <abstractions/bash>
          include <abstractions/consoles>
          include <abstractions/nameservice>
          deny capability sys_ptrace,
          owner /** rkl,
          @{PROC}/** r,
          /nix/store/*/bin/** Pixmr,
          /run/current-system/sw/bin/* Pixmr,
          owner @{HOMEDIRS}/ w,
          owner @{HOMEDIRS}/** w,
        }

        profile confined_user {
          include <abstractions/base>
          include <abstractions/bash>
          include <abstractions/consoles>
          include <abstractions/nameservice>
          deny capability sys_ptrace,
          owner /** rwkl,
          @{PROC}/** r,
          /nix/store/*/bin/** Pixmr,
          /run/current-system/sw/bin/* Pixmr,
        }
      '';

      "pam_binaries".profile = ''
        include <tunables/global>

        ${pkgs.util-linux}/sbin/agetty {
          include <abstractions/authentication>
          include <abstractions/base>
          include <abstractions/nameservice>
          include <pam/mappings>
          include "${makeAppArmorRulesFromClosure "util-linux" pkgs.util-linux.buildInputs}"

          capability chown,
          capability setgid,
          capability setuid,
          owner /etc/environment r,
          owner /etc/shells r,
          owner /etc/default/locale r,
          owner @{HOMEDIRS}/*/.Xauthority rw,
          owner @{HOMEDIRS}/*/.Xauthority-c w,
          owner @{HOMEDIRS}/*/.Xauthority-l w,
          @{HOME}/.xauth* rw,
          owner @{PROC}/sys/kernel/ngroups_max r,
          owner /var/run/utmp rwk,
        }

        ${pkgs.shadow.su}/bin/su {
          include <abstractions/authentication>
          include <abstractions/base>
          include <abstractions/nameservice>
          include <pam/mappings>
          include "${makeAppArmorRulesFromClosure "su" pkgs.shadow.buildInputs}"

          capability chown,
          capability setgid,
          capability setuid,
          owner /etc/environment r,
          owner /etc/shells r,
          owner /etc/default/locale r,
          owner @{HOMEDIRS}/*/.Xauthority rw,
          owner @{HOMEDIRS}/*/.Xauthority-c w,
          owner @{HOMEDIRS}/*/.Xauthority-l w,
          @{HOME}/.xauth* rw,
          owner @{PROC}/sys/kernel/ngroups_max r,
          owner /var/run/utmp rwk,
        }
      '';
    };
in
{
  config.security.apparmor = {
    inherit policies;
    includes = {
      "pam/mappings" = ''
        ^DEFAULT {
          include <abstractions/authentication>
          include <abstractions/nameservice>
          capability dac_override,
          capability setgid,
          capability setuid,
          /etc/default/su r,
          /etc/environment r,
          @{HOMEDIRS}/.xauth* w,
          /run/current-system/sw/bin/{,b,d,rb}ash Px -> default_user,
          /run/current-system/sw/bin/{c,k,tc}sh Px -> default_user,
        }
      '';
    };
  };
}
