{
  description = "SDK for ExpidusOS";

  outputs = { self }@inputs:
    let
      nixpkgs-lib = import ./lib;
      currentSystem = if builtins.hasAttr "currentSystem" builtins then builtins.toString builtins.currentSystem else "x86_64-linux";

      linuxSystems = [
        "armv6l-linux"
        "aarch64-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];

      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ] ++ linuxSystems;
      
      forAllLinuxSystems = nixpkgs-lib.genAttrs linuxSystems;
      forAllSystems = nixpkgs-lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import ./. { inherit system; });

      emptyPackages = { buildInputs = []; nativeBuildInputs = []; propagatedBuildInputs = []; devShell = []; nixosModules = []; };

      nixos = import ./nixos/lib {};
      nixosSystem = args:
        import ./nixos/lib/eval-config.nix (args // {
          modules = args.modules ++ [(({
            system.nixos.versionSuffix = ".${builtins.substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101")}.${self.shortRev or "dirty"}";
            system.nixos.revision = nixpkgs-lib.mkIf (self ? rev) self.rev;
          }) // (nixpkgs-lib.optionalAttrs (! args?system) {
            system = null;
          }))];
        });

      libExpidus = nixpkgs-lib.expidus // {
        inherit forAllSystems forAllLinuxSystems nixpkgsFor supportedSystems nixos nixosSystem;

        mkFlake = {
          self,
          target ? "default",
          name,
          systems ? supportedSystems,
          packagesFor ? ({ final, prev, old }: emptyPackages)
        }@flake:
          let
            forAllSystems = nixpkgs-lib.genAttrs systems;
          in {
            overlays.${target} = final: prev: {
              ${name} = if name == "expidus-sdk" then (prev.callPackage ./pkgs/development/tools/expidus-sdk {}) else (prev.${name}.overrideAttrs (old:
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
              systems = forAllLinuxSystems (system:
                let
                  base-pkgs = nixpkgsFor.${system};
                  pkgs = self.overlays.${target} base-pkgs base-pkgs;

                  pkg = self.packages.${system}.${target};
                  packages = emptyPackages // (packagesFor { final = pkgs; prev = packages; old = pkg; });
                in nixosSystem {
                  inherit system;
                  specialArgs = { inherit flake; };

                  pkgs = import ./. {
                    inherit system;
                    overlays = [ self.overlays.${target} ];
                  };
                
                  modules = [
                    ./nixos/dev.nix
                    {
                      environment.systemPackages = [ pkg ];
                      virtualisation.sharedDirectories.source-code = {
                        source = builtins.toString self;
                        target = "/home/expidus-devel/source";
                        options = [ "uname=developer" ];
                      };
                    }
                  ] ++ packages.nixosModules;
                });
              in systems // {
                ${target} = if builtins.hasAttr currentSystem systems then systems.${currentSystem} else null;
              });

            devShells = forAllSystems (system:
              let
                pkgs = nixpkgsFor.${system};
                pkg = self.packages.${system}.${target};
                packages = emptyPackages // (packagesFor { final = pkgs; prev = packages; old = pkg; });
                wrappedTarget = if target == "default" then "wrapped" else target + "-wrapped";
              in {
                ${target} = pkgs.mkShell {
                  name = name + (if target == "default" then "" else "-${target}");
                  packages = pkg.nativeBuildInputs ++ pkg.buildInputs ++ packages.devShell ++ [ inputs.self.packages.${system}.${target} ];
                };
                ${wrappedTarget} = pkgs.mkShell {
                  name = name + (if target == "default" then "" else "-${target}") + "-wrapped";
                  packages = [ pkg inputs.self.packages.${system}.default ];
                };
              });
          };
        };

      lib = nixpkgs-lib.extend (final: prev: {
        expidus = libExpidus;
      });

      sdk-flake = libExpidus.mkFlake { inherit self; name = "expidus-sdk"; };
    in sdk-flake // ({
      inherit libExpidus lib self;
      legacyPackages = forAllSystems (system: import ./pkgs { inherit system; });
    });
}
