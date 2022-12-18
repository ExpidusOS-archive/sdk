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

  makeBaseAbstraction = name: text: ''
    include "${pkgs.apparmor-profiles}/etc/apparmor.d/abstractions/${name}"
    ${text}
  '';

  makeNewAbstraction = name: text: {
    "abstractions/${name}" = text;
  };

  makeAbstractionForce = name: text: {
    "abstractions/${name}" = lib.mkForce (makeBaseAbstraction name text);
  };

  makeAbstraction = name: text: {
    "abstractions/${name}" = makeBaseAbstraction name text;
  };
in
{
  config.security.apparmor.includes =
    (makeAbstractionForce "bash" ''
      r @{PROC}/mounts,

      ${concatMapStringsSep "\n" etcRule [
        "profile.dos"
        "profile"
        "profile.d"
        { path = "profile.d";  trail = "/*"; }
        "bashrc"
        "bash.bashrc"
        "bash.bashrc.local"
        "bash_completion"
        "bash_completion.d"
        { path = "bash_completion.d";  trail = "/*"; }
        "inputrc"
        "DIR_COLORS"
      ]}
    '')
    // (makeAbstraction "dri-common" "")
    // (makeAbstraction "dri-enumerate" "")
    // (makeAbstraction "wayland" "")
    // (makeNewAbstraction "libseat" ''
      include <abstractions/dbus-session-strict>

      dbus bus=session,
      r @{run}/systemd/sessions/*,
    '');
}
