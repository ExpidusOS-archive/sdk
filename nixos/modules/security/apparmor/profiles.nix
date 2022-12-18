{ config, lib, pkgs, ... }:
let
  inherit (builtins) attrNames hasAttr isAttrs;
  inherit (lib) getLib concatMapStringsSep isDerivation;
  inherit (config.environment) etc;

  etcRule = arg:
    let go = { path ? null, mode ? "r", trail ? "" }:
      if (hasAttr path etc) then "${mode} ${config.environment.etc.${path}.source}${trail},"
      else "${mode} /etc/${path}${trail},";
    in if isAttrs arg
    then go arg
    else go { path = arg; };

  drvBinRule = arg:
    let go = { derivation ? null, mode ? "PUxmr" }:
      "${derivation}/bin/* ${mode},";
    in if isDerivation arg
    then go { derivation = arg; }
    else go arg;

  drvBinRuleProfile = arg:
    let go = { derivation ? null, mode ? "Px", profile ? "default_user" }:
      "${derivation}/bin/* ${mode} -> default_user,";
    in if isDerivation arg
    then go { derivation = arg; }
    else go arg;

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
          include "${makeAppArmorRulesFromClosure "default_user" config.environment.systemPackages}"
          ${concatMapStringsSep "\n" drvBinRule config.environment.systemPackages}
          deny capability sys_ptrace,
          owner /** rkl,
          @{PROC}/** r,
          owner @{HOMEDIRS}/ w,
          owner @{HOMEDIRS}/** w,
          /run/current-system/sw/bin/* Pixmr,
        }

        profile confined_user {
          include <abstractions/base>
          include <abstractions/bash>
          include <abstractions/consoles>
          include <abstractions/nameservice>
          include "${makeAppArmorRulesFromClosure "confined_user" config.environment.systemPackages}"
          ${concatMapStringsSep "\n" drvBinRule config.environment.systemPackages}
          deny capability sys_ptrace,
          owner /** rwkl,
          @{PROC}/** r,
          /run/current-system/sw/bin/* Pixmr,
        }
      '';

      "pam_binaries".profile =
        let
          commonProfile = pkg: ''
            include <abstractions/authentication>
            include <abstractions/base>
            include <abstractions/nameservice>
            include <pam/mappings>
            include "${makeAppArmorRulesFromClosure "su" (pkg.buildInputs ++ (with pkgs; [ libykclient readline81 ]))}"

            /dev/tty* rw,
            /dev/kmsg rw,

            capability chown,
            capability setgid,
            capability setuid,
            capability audit_write,
            owner @{HOMEDIRS}/*/.Xauthority rw,
            owner @{HOMEDIRS}/*/.Xauthority-c w,
            owner @{HOMEDIRS}/*/.Xauthority-l w,
            @{HOME}/.xauth* rw,
            owner @{PROC}/sys/kernel/ngroups_max r,
            @{PROC}/[0-9]*/loginuid r,
            @{run}/utmp rwk,
            /var/run/utmp rwk,
            /nix/store/*-etc-environment r,
            ${concatMapStringsSep "\n" etcRule [
              "shells"
              "bashrc"
            ]}
          '';
        in ''
          include <tunables/global>

          ${pkgs.shadow.su}/bin/su {
            ${commonProfile pkgs.shadow}
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
          /nix/store/*-etc-environment r,
          @{HOMEDIRS}/.xauth* w,
          ${concatMapStringsSep "\n" drvBinRuleProfile config.environment.systemPackages}
        }

        ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: user: ''
          ^${user.name or name} {
            include <abstractions/authentication>
            include <abstractions/nameservice>
            capability dac_override,
            capability setgid,
            capability setuid,
            /nix/store/*-etc-environment r,
            @{HOMEDIRS}/.xauth* w,
            ${concatMapStringsSep "\n" drvBinRuleProfile config.environment.systemPackages}
          }
        '') (lib.filterAttrs (name: user: user.isNormalUser) config.users.users)))}
      '';
    };
  };
}
