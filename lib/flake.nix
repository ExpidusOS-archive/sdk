{ lib, expidus }:
rec {
  emptyPackages = { buildInputs = []; nativeBuildInputs = []; propagatedBuildInputs = []; devShell = []; nixosModules = []; };

  make = {
    self,
    target ? "default",
    name,
    systems ? expidus.system.supported,
    packagesFor ? ({ final, prev, old }: emptyPackages)
  }@flake:
    let
      sysconfig = expidus.system.make { supported = systems; };

      nixpkgsFor = sysconfig.forAll (system: import ../pkgs/top-level/default.nix {
        system = sysconfig.current;
        crossSystem = { inherit system; };
      });
      wrapped = name + (if target == "default" then "" else "-${target}");

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
          base-pkgs = nixpkgsFor.${system};
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
                source = builtins.toString self;
                target = "/home/expidus-devel/source";
                options = [ "uname=developer" ];
              };
            }
          ];
        });

      vmTarget = if target == "default" then "vm" else target + "-vm";
    in {
      overlays.${target} = packageOverlay;

      legacyPackages = sysconfig.forAll (system:
        let
          pkgs = nixpkgsFor.${system};
        in (packageOverlay pkgs pkgs));

      packages = sysconfig.forAll (system:
        let
          pkgs = nixpkgsFor.${system};
        in ({
          ${target} = (packageOverlay pkgs pkgs).${name};
        }) // (if builtins.hasAttr system nixosSystems then {
          ${vmTarget} = nixosSystems.${system}.config.system.build.vm;
        } else {}));

      nixosConfigurations = (nixosSystems // {
        ${target} = if builtins.hasAttr expidus.system.current nixosSystems then nixosSystems.${expidus.system.current} else null;
      });

      hydraJobs = {
        ${target} = sysconfig.forAllLinux (system:
          let
            pkgs = nixpkgsFor.${system};
          in (packageOverlay pkgs pkgs).${name});
        ${vmTarget} = sysconfig.forAllLinux (system: nixosSystems.${system}.config.system.build.vm);
      };

      devShells = sysconfig.forAll (system:
        let
          pkgs = nixpkgsFor.${system};
          pkg = self.packages.${system}.${target};
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
    systems ? expidus.system.supported,
    packagesFor ? ({ final, prev, old }: emptyPackages)
  }: make {
    inherit self target name systems;
    packagesFor = ({ final, prev, old }@args:
      let
        packages = emptyPackages // (packagesFor args);
      in packages // {
        overlay = {
          ${name} = if name == "expidus-sdk" then
            (prev.callPackage ../pkgs/development/tools/expidus-sdk {})
          else
            (prev.${name}.overrideAttrs (old: {
              version = self.rev or "dirty";
              src = self;
            }));
        };
      });
  };
}
