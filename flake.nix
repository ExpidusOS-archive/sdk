{
  description = "SDK for ExpidusOS";

  outputs = { self }@inputs:
    let
      nixpkgs-lib = import ((import ./lib/nixpkgs.nix) + "/lib/");

      supportedSystems = [
        "armv6l-linux"
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs-lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import ./pkgs { inherit system; });

      emptyPackages = { buildInputs = []; nativeBuildInputs = []; propagatedBuildInputs = []; devShell = []; };

      lib = import ./lib/extend.nix // {
        inherit forAllSystems nixpkgsFor supportedSystems;

        nixos = import ./nixos/lib {};
        nixosSystem = args:
          import ./nixos/lib/eval-config.nix (args // {
            modules = args.modules ++ [{
              system.nixos.versionSuffix = self.shortRev or "dirty";
              system.nixos.revision = self.rev;
            }];
          });

        mkFlake = {
          self,
          target ? "default",
          name,
          packagesFor ? ({ final, prev, old }: emptyPackages)
        }: {
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
              ${target} = (self.overlays.default pkgs pkgs).${name};
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
                packages = pkg.nativeBuildInputs ++ pkg.buildInputs ++ packages.devShell ++ [ inputs.self.packages.${system}.default ];
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
      inherit lib;
      legacyPackages = forAllSystems (system: import ./pkgs { inherit system; });
    } // (lib.mkFlake { inherit self; name = "expidus-sdk"; });
}
