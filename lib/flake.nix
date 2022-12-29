{ lib, expidus }:
rec {
  /*
    An empty packages set for "make"'s packagesFor
  */
  emptyPackages = { buildInputs = []; nativeBuildInputs = []; propagatedBuildInputs = []; devShell = []; nixosModules = []; };

  make = {
    self,
    target ? "default",
    name,
    sysconfig ? expidus.system,
    packagesFor ? ({ final, prev, old }: emptyPackages)
  }@flake:
    let
      nixpkgsFor = sysconfig.forAllPossible (host:
        sysconfig.forAllPossible (target: import ../pkgs/top-level/default.nix {
          system = host;
          crossSystem = {
            system = target;
          };
        }));
      wrapped = name + (if target == "default" then "" else "-${target}");
      makeWrapped = key: if target == "default" then key else target + "-${key}";

      packageOverlay = final: prev:
        let
          packages = emptyPackages // (packagesFor {
            inherit final prev;
            old = prev.${name};
          });
        in builtins.mapAttrs (name: pkg:
          pkg.overrideAttrs (old:
            let
              separateDebugInfo = if prev.stdenv.isDarwin then false else true;
              config = if name == flake.name then packages else (packages.${name} or emptyPackages);
              overrideAttr = name: if builtins.hasAttr name old then old.${name} ++ config.${name} else [];
            in {
              inherit separateDebugInfo;
              nativeBuildInputs = overrideAttr "nativeBuildInputs";
              buildInputs = overrideAttr "buildInputs";
              propagatedBuildInputs = overrideAttr "propagatedBuildInputs";

              meta = old.meta // {
                outputsToInstall = old.meta.outputsToInstall or [ "out" ] ++ (prev.lib.optional separateDebugInfo "debug");
              };
            })) packages.overlay;

      nixosSystems = sysconfig.forAllLinux (system:
        let
          base-pkgs = nixpkgsFor.${system}.${system};
          pkgs = packageOverlay base-pkgs base-pkgs;

          pkg = pkgs.${name};
          packages = emptyPackages // (packagesFor {
            final = pkgs;
            prev = packages;
            old = pkg;
          });

          nixosSystem = if builtins.hasAttr "nixosSystem" lib then lib.nixosSystem
          else import ../nixos/lib/eval-config.nix;
        in nixosSystem {
          inherit system;

          lib = lib.extend (self: prev: {
            inherit expidus;
          });

          pkgs = base-pkgs.appendOverlays ([
            packageOverlay
          ]);

          modules = [
            ../nixos/dev.nix
            {
              environment.systemPackages = [ pkg ];
              virtualisation.sharedDirectories.source-code = {
                source = self.outPath;
                target = "/home/expidus-devel/source";
                options = [ "uname=developer" ];
              };
            }
          ];
        });
    in {
      overlays.${target} = packageOverlay;

      metadata = {
        inherit target name sysconfig nixpkgsFor;
      };

      legacyPackages = sysconfig.forAllPossible (system:
        let
          pkgs = nixpkgsFor.${system}.${system};
        in (packageOverlay pkgs pkgs));

      packages = sysconfig.forAllPossible (system:
        let
          nixpkgsTarget = nixpkgsFor.${system};
          syshost = expidus.system.make {
            currentSystem = system;
            supported = sysconfig.possible;
          };
          pkgs = nixpkgsTarget.${system};
          forAllSystems = lib.genAttrs (builtins.map makeWrapped syshost.supported);
        in ({
          ${target} = (packageOverlay pkgs pkgs).${name};
        }) // forAllSystems (system:
          let
            pkgs = nixpkgsTarget.${system};
          in (packageOverlay pkgs pkgs).${name}
        ) // (if builtins.hasAttr system nixosSystems then {
          ${makeWrapped "vm"} = nixosSystems.${system}.config.system.build.vm;
        } else {}));

      nixosConfigurations = (nixosSystems // {
        ${target} = if builtins.hasAttr expidus.system.current nixosSystems then nixosSystems.${expidus.system.current} else null;
      });

      hydraJobs = {
        ${target} = sysconfig.forAllLinux (system:
          let
            pkgs = nixpkgsFor.${system}.${system};
          in (packageOverlay pkgs pkgs).${name});
        ${makeWrapped "vm"} = sysconfig.forAllLinux (system: nixosSystems.${system}.config.system.build.vm);
      };

      devShells = sysconfig.forAllPossible (system:
        let
          pkgs = nixpkgsFor.${system}.${system};
          pkg = (packageOverlay pkgs pkgs).${name};
          packages = emptyPackages // (packagesFor { final = pkgs; prev = packages; old = pkg; });
          wrappedTarget = if target == "default" then "wrapped" else target + "-wrapped";
        in {
          ${target} = pkgs.mkShell {
            name = wrapped;
            packages = pkg.nativeBuildInputs ++ pkg.buildInputs ++ packages.devShell ++ [ pkgs.expidus-sdk ];
          };
          ${wrappedTarget} = pkgs.mkShell {
            name = "${wrapped}-wrapped";
            packages = [ pkg pkgs.expidus-sdk ];
          };
        });
    };

  makeOverride = {
    self,
    target ? "default",
    name,
    sysconfig ? expidus.system,
    packagesFor ? ({ final, prev, old }: emptyPackages)
  }: make {
    inherit self target name sysconfig;
    packagesFor = ({ final, prev, old }@args:
      let
        packages = emptyPackages // (packagesFor args);
      in packages // {
        overlay = {
          ${name} = if name == "expidus-sdk" then
            (prev.callPackage ../pkgs/development/tools/expidus-sdk {})
          else
            (prev.${name}.overrideAttrs (old:
              let
                src = if builtins.isFunction self then self prev else self;
              in {
                version = src.rev or "dirty";
                inherit src;
              }));
        };
      });
  };

  makeSubmodules = src: inputs: pkgs:
    let
      makeEntry = key: input: ''
        mkdir -p $(dirname $out/${key})
        rm -rf $out/${key}
        cp -r ${input.outPath} $out/${key}
      '';

      id = lib.removePrefix "${builtins.storeDir}/" src.outPath;

      passAttr = attr:
        if builtins.hasAttr attr src then
          {
            "${attr}" = src.${attr};
          }
        else {};
    in pkgs.stdenvNoCC.mkDerivation ({
      name = "${id}-with-submodules";
      src = lib.cleanSource src.outPath;
      srcs = builtins.map (drv: drv.outPath) (builtins.attrValues inputs);
      sourceRoot = ".";

      buildCommand = ''
        shopt -s dotglob
        mkdir -p $out
        ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs makeEntry inputs))}
        cp -r $src/* $out
      '';

      submodules = true;
    } // passAttr "rev");
}
