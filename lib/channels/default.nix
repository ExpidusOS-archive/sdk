let
  nameValuePair = name: value: { inherit name value; };
  genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
  forAllChannels = genAttrs ["home-manager" "nixpkgs" "sdk" "mobile-nixos"];
in forAllChannels (name:
  let
    key = builtins.replaceStrings [ "-" ] [ "_" ] name;
    env = builtins.getEnv "EXPIDUS_SDK_CHANNEL_${key}_PATH";
  in if env != "" then
    env
  else import ./${name}.nix)
