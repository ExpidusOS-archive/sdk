{ lib, expidus }:
rec {
  emptyPackages = { buildInputs = []; nativeBuildInputs = []; propagatedBuildInputs = []; devShell = []; nixosModules = []; };

  make = {
    self,
    target ? "default",
    name,
    systems ? expidus.system.supported,
    packagesFor ? emptyPackages
  }:
    let
      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: import ../pkgs {
        inherit system;
        inherit (self) channels;
      });
      wrapped = name + (if target == "default" then "" else "-${target}");
    in {
      overlays.${target} = final: prev: {
        ${name} =
          if name == "expidus-sdk" then
            (prev.callPackage ../pkgs/development/tools/expidus-sdk {})
          else
            (prev.${name}.overrideAttrs (old:
              let
                packages = emptyPackages // (packagesFor { inherit final prev old; });
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
      };

      legacyPackages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in (self.overlays.${target} pkgs pkgs));

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in {
          ${target} = (self.overlays.${target} pkgs pkgs).${name};
        });

      nixosConfigurations = (let
        systems = expidus.system.forAllLinux (system:
          let
            base-pkgs = nixpkgsFor.${system};
            pkgs = self.overlays.${target} base-pkgs base-pkgs;

            pkg = pkgs.${target};
            packages = emptyPackages // (packagesFor {
              final = pkgs;
              prev = packages;
              old = pkg;
            });
          in import ../nixos {
            inherit system lib;

            pkgs = base-pkgs.appendOverlays ([
              self.overlays.${target}
            ]);
          });
      in systems // {
        ${target} = if builtins.hasAttr self.system.current systems then systems.${self.system.current} else null;
      });

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
}
