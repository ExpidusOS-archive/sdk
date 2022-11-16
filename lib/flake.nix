{ lib, expidus }:
rec {
  emptyPackages = { buildInputs = []; nativeBuildInputs = []; propagatedBuildInputs = []; devShell = []; nixosModules = []; };

  make = {
    self,
    target ? "default",
    name,
    systems ? expidus.system.supported,
    packagesFor ? ({ final, prev, old }: emptyPackages)
  }:
    let
      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: import ../pkgs/top-level/default.nix {
        inherit system;
        inherit (self) channels;
      });
      wrapped = name + (if target == "default" then "" else "-${target}");

      packageOverlay = final: prev:
        let
          packages = emptyPackages // (packagesFor {
            inherit final prev;
            old = prev.${name};
          });
        in {
          ${name} = packages.overlay;
        };

      nixosSystems = expidus.system.forAllLinux (system:
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
            self.overlays.${target}
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
    in {
      overlays.${target} = packageOverlay;

      legacyPackages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in (packageOverlay pkgs pkgs));

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in {
          ${target} = (packageOverlay pkgs pkgs).${name};
        });

      nixosConfigurations = (nixosSystems // {
        ${target} = if builtins.hasAttr expidus.system.current nixosSystems then nixosSystems.${expidus.system.current} else null;
      });

      hydraJobs = {
        ${target} = expidus.system.forAllLinux (system:
          let
            pkgs = nixpkgsFor.${system};
          in (packageOverlay pkgs pkgs).${name});
        "${target}-devvm" = expidus.system.forAllLinux (system: nixosSystems.${system}.config.system.build.vm);
      };

      devShells = forAllSystems (system:
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
        overlay = if name == "expidus-sdk" then
          (prev.callPackage ../pkgs/development/tools/expidus-sdk {})
        else
          (prev.${name}.overrideAttrs (old:
            let
              separateDebugInfo = if prev.stdenv.isDarwin then false else true;
            in {
              version = self.rev or "dirty";
              src = builtins.path {
                inherit name;
                path = prev.lib.cleanSource (builtins.toString self);
              };

              inherit separateDebugInfo;
              nativeBuildInputs = if builtins.hasAttr "nativeBuildInputs" old then old.nativeBuildInputs ++ packages.nativeBuildInputs else [];
              buildInputs = if builtins.hasAttr "buildInputs" old then old.buildInputs ++ packages.buildInputs else [];
              propagatedBuildInputs = if builtins.hasAttr "propagatedBuildInputs" old then old.propagatedBuildInputs ++ packages.propagatedBuildInputs else [];

              meta = old.meta // {
                outputsToInstall = old.meta.outputsToInstall or [ "out" ] ++ (prev.lib.optional separateDebugInfo "debug");
              };
            }));
      });
  };
}
