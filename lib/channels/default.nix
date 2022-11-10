let
  nameValuePair = name: value: { inherit name value; };
  genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair "${n}Path" (f n)) names);
  forAllChannels = genAttrs ["home-manager" "nixpkgs"];
in forAllChannels (name: import ./${name}.nix)
