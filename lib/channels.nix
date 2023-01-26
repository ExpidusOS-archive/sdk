let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  nodes = builtins.removeAttrs lock.nodes [ "root" ];

  fetchTree = info:
    if info.type == "github" then
      fetchTarball ({
        url = "https://api.${info.host or "github.com"}/repos/${info.owner}/${info.repo}/tarball/${info.rev}";
      } // (if info ? narHash then { sha256 = info.narHash; } else {}))
    else throw "Unsupported type ${info.type}";
in (builtins.mapAttrs
  (name: node: fetchTree (node.locked // node.original))
  nodes) // {
    expidus-sdk = ../.;
  }
