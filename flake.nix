{
  description = "SDK for ExpidusOS";

  outputs = { self }@inputs:
    let
      nixpkgs-lib = import ((import ./lib/nixpkgs.nix) + "/lib/");
      currentSystem = builtins.toString builtins.currentSystem;

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
      nixpkgsFor = forAllSystems (system: import ./pkgs { inherit system; });

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

      lib = import ./lib/extend.nix // {
        inherit forAllSystems nixpkgsFor supportedSystems nixos nixosSystem;

        mkFlake = {
          self,
          target ? "default",
          name,
          packagesFor ? ({ final, prev, old }: emptyPackages)
        }@flake: {
          overlays.${target} = final: prev: {
            ${name} = (prev.${name}.overrideAttrs (old:
            let
              packages = emptyPackages // (packagesFor { inherit final prev old; });
            in {
              version = self.rev or "dirty";
              src = builtins.path {
                inherit name;
                path = prev.lib.cleanSource (builtins.toString self);
              };

              nativeBuildInputs = if builtins.hasAttr "nativeBuildInputs" old then old.nativeBuildInputs ++ packages.nativeBuildInputs else [];
              buildInputs = if builtins.hasAttr "buildInputs" old then old.buildInputs ++ packages.buildInputs else [];
              propagatedBuildInputs = if builtins.hasAttr "propagatedBuildInputs" old then old.propagatedBuildInputs ++ packages.propagatedBuildInputs else [];
            }));
          };

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

                pkgs = import ./pkgs {
                  inherit system;
                  overlays = [ self.overlays.${target} ];
                };
                
                modules = [
                  ./nixos/dev.nix
                  {
                    environment.systemPackages = [ pkg ];
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

      packagesFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in with pkgs; {
          nativeBuildInputs = [ meson ninja pkg-config ];
          buildInputs = [ uncrustify clang_14 vala ];
        });
    in rec {
      inherit lib self;
      legacyPackages = forAllSystems (system: import ./pkgs { inherit system; });
    } // (lib.mkFlake { inherit self; name = "expidus-sdk"; });
}
