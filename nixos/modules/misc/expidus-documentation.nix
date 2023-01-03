{ config, options, lib, pkgs, utils, modules, baseModules, extraModules, modulesPath, specialArgs, ... }:
with lib;
let
  cfg = config.documentation;
  allOpts = options;

  canCacheDocs = m:
    let
      f = import m;
      instance = f (mapAttrs (n: _: abort "evaluating ${n} for `meta` failed") (functionArgs f));
    in
      cfg.expidus.options.splitBuild
        && builtins.isPath m
        && isFunction f
        && instance ? options
        && instance.meta.buildDocsInSandbox or true;

  docModules =
    let
      modules = baseModules ++ cfg.expidus.extraModules;
      p = partition canCacheDocs modules;
    in
      {
        lazy = p.right;
        eager = p.wrong ++ optionals cfg.expidus.includeAllModules modules;
      };

  manual = import ../../doc/manual rec {
    inherit pkgs config;
    version = config.system.expidus.release;
    revision = "release-${version}";
    extraSources = cfg.expidus.extraModuleSources;
    options =
      let
        scrubbedEval = evalModules {
          modules = [ {
            _module.check = false;
          } ] ++ docModules.eager;
          specialArgs = specialArgs // {
            pkgs = scrubDerivations "pkgs" pkgs;
            # allow access to arbitrary options for eager modules, eg for getting
            # option types from lazy modules
            options = allOpts;
            inherit modulesPath utils;
          };
        };
        scrubDerivations = namePrefix: pkgSet: mapAttrs
          (name: value:
            let wholeName = "${namePrefix}.${name}"; in
            if isAttrs value then
              scrubDerivations wholeName value
              // (optionalAttrs (isDerivation value) { outPath = "\${${wholeName}}"; })
            else value
          )
          pkgSet;
      in scrubbedEval.options;

    baseOptionsJSON =
      let
        filter =
          builtins.filterSource
            (n: t:
              cleanSourceFilter n t
              && (t == "directory" -> baseNameOf n != "tests")
              && (t == "file" -> hasSuffix ".nix" n)
            );

        sdkPath = (toString pkgs.path);
      in
        pkgs.runCommand "lazy-options.json" {
          libPath = filter "${toString pkgs.path}/lib";
          pkgsLibPath = filter "${toString lib.expidus.channels.nixpkgs}/pkgs/pkgs-lib";
          nixosPath = filter "${toString lib.expidus.channels.nixpkgs}/nixos";
          nixpkgsPath = filter "${toString lib.expidus.channels.nixpkgs}";
          homeManagerPath = filter "${toString lib.expidus.channels.home-manager}";
          mobileNixosPath = filter "${toString lib.expidus.channels.mobile-nixos}";
          diskoPath = filter "${toString lib.expidus.channels.disko}";
          sdkPath = filter "${sdkPath}";
          modulesPath = filter "${toString sdkPath}/nixos/modules";
          modules = lib.flatten (map (p:
            let
              path = toString p;
              paths = builtins.mapAttrs (name: channel:
                let
                  unprefixed = removePrefix channel path;
                  isChanged = path != unprefixed;
                  value = ''"[${name}]${unprefixed}"'';
                in if isChanged then
                  value
                else "") (lib.expidus.channels // { sdk = "${sdkPath}/nixos/modules"; });
              filtered = builtins.filter (value: value != "") (builtins.attrValues paths);
            in filtered) docModules.lazy);
        } ''
          export NIX_STORE_DIR=$TMPDIR/store
          export NIX_STATE_DIR=$TMPDIR/state
          export EXPIDUS_SDK_CHANNEL_nixpkgs_PATH=$nixpkgsPath
          export EXPIDUS_SDK_CHANNEL_sdk_PATH=$sdkPath
          export EXPIDUS_SDK_CHANNEL_home_manager_PATH=$homeManagerPath
          export EXPIDUS_SDK_CHANNEL_mobile_nixos_PATH=$mobileNixosPath
          export EXPIDUS_SDK_CHANNEL_disko_PATH=$diskoPath
          ${pkgs.buildPackages.nix}/bin/nix-instantiate \
            --show-trace \
            --eval --json --strict \
            --argstr libPath "$libPath" \
            --argstr pkgsLibPath "$pkgsLibPath" \
            --argstr nixosPath "$nixosPath" \
            --argstr nixpkgsPath "$nixpkgsPath" \
            --argstr homeManagerPath "$homeManagerPath" \
            --argstr mobileNixosPath "$mobileNixosPath" \
            --argstr diskoPath "$diskoPath" \
            --argstr modulesPath "$modulesPath" \
            --argstr sdkPath "$sdkPath" \
            --arg modules "[ $modules ]" \
            --argstr stateVersion "${lib.version}" \
            --argstr release "${config.system.expidus.release}" \
            $sdkPath/nixos/lib/eval-cacheable-options.nix > $out \
            || {
              echo -en "\e[1;31m"
              echo 'Cacheable portion of option doc build failed.'
              echo 'Usually this means that an option attribute that ends up in documentation (eg' \
                '`default` or `description`) depends on the restricted module arguments' \
                '`config` or `pkgs`.'
              echo
              echo 'Rebuild your configuration with `--show-trace` to find the offending' \
                'location. Remove the references to restricted arguments (eg by escaping' \
                'their antiquotations or adding a `defaultText`) or disable the sandboxed' \
                'build for the failing module by setting `meta.buildDocsInSandbox = false`.'
              echo -en "\e[0m"
              exit 1
            } >&2
        '';

    inherit (cfg.expidus.options) warningsAreErrors allowDocBook;
  };


  expidus-help = let
    helpScript = pkgs.writeShellScriptBin "expidus-help" ''
      # Finds first executable browser in a colon-separated list.
      # (see how xdg-open defines BROWSER)
      browser="$(
        IFS=: ; for b in $BROWSER; do
          [ -n "$(type -P "$b" || true)" ] && echo "$b" && break
        done
      )"
      if [ -z "$browser" ]; then
        browser="$(type -P xdg-open || true)"
        if [ -z "$browser" ]; then
          browser="${pkgs.w3m-nographics}/bin/w3m"
        fi
      fi
      exec "$browser" ${manual.manualHTMLIndex}
    '';

    desktopItem = pkgs.makeDesktopItem {
      name = "expidus-manual";
      desktopName = "ExpidusOS Manual";
      genericName = "View ExpidusOS documentation in a web browser";
      icon = "nix-snowflake";
      exec = "expidus-help";
      categories = ["System"];
    };

    in pkgs.symlinkJoin {
      name = "expidus-help";
      paths = [
        helpScript
        desktopItem
      ];
    };
in
{
  options = {
    documentation.expidus = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Whether to install ExpidusOS's own documentation.

          - This includes man pages like
            {manpage}`configuration.nix(5)` if {option}`documentation.man.enable` is
            set.
          - This includes the HTML manual and the {command}`expidus-help` command if
            {option}`documentation.doc.enable` is set.
        '';
      };

      extraModules = mkOption {
        type = types.listOf types.raw;
        default = [];
        description = lib.mdDoc ''
          Modules for which to show options even when not imported.
        '';
      };

      options.splitBuild = mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Whether to split the option docs build into a cacheable and an uncacheable part.
          Splitting the build can substantially decrease the amount of time needed to build
          the manual, but some user modules may be incompatible with this splitting.
        '';
      };

      options.allowDocBook = mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Whether to allow DocBook option docs. When set to `false` all option using
          DocBook documentation will cause a manual build error; additionally a new
          renderer may be used.

          ::: {.note}
          The `false` setting for this option is not yet fully supported. While it
          should work fine and produce the same output as the previous toolchain
          using DocBook it may not work in all circumstances. Whether markdown option
          documentation is allowed is independent of this option.
          :::
        '';
      };

      options.warningsAreErrors = mkOption {
        type = types.bool;
        default = false; # https://github.com/nix-community/disko/pull/103
        description = lib.mdDoc ''
          Treat warning emitted during the option documentation build (eg for missing option
          descriptions) as errors.
        '';
      };

      includeAllModules = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether the generated ExpidusOS's documentation should include documentation for all
          the options from all the ExpidusOS modules included in the current
          `configuration.nix`. Disabling this will make the manual
          generator to ignore options defined outside of `baseModules`.
        '';
      };

      extraModuleSources = mkOption {
        type = types.listOf (types.either types.path types.str);
        default = [ ];
        description = lib.mdDoc ''
          Which extra ExpidusOS module paths the generated ExpidusOS's documentation should strip
          from options.
        '';
        example = literalExpression ''
          # e.g. with options from modules in ''${pkgs.customModules}/nix:
          [ pkgs.customModules ]
        '';
      };

    };

  };

  config = (mkIf cfg.expidus.enable {
    system.build.expidus-manual = manual;

    environment.systemPackages = []
      ++ optional cfg.man.enable manual.manpages
      ++ optionals cfg.doc.enable [ manual.manualHTML expidus-help ];
  });
}
