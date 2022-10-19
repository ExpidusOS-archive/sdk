{
  description = "SDK for ExpidusOS";

  outputs = { self }@inputs:
    let
      nixpkgs-lib = import ((import ./lib/nixpkgs.nix) + "/lib/");

      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs-lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import ./pkgs { inherit system; });

      emptyPackages = { buildInputs = []; nativeBuildInputs = []; propagatedBuildInputs = []; devShell = []; };

      lib = import ./lib/extend.nix // {
        inherit forAllSystems nixpkgsFor supportedSystems;

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

              nativeBuildInputs = old.nativeBuildInputs ++ packages.nativeBuildInputs;
              buildInputs = old.buildInputs ++ packages.buildInputs;
              propagatedBuildInputs = old.propagatedBuildInputs ++ packages.propagatedBuildInputs;
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
            in {
              ${target} = pkgs.mkShell {
                packages = pkg.nativeBuildInputs ++ pkg.buildInputs ++ packages.devShell ++ [ inputs.self.packages.${system}.default ];
              };
              ${if target == "default" then "wrapped" else target + "-wrapped"} = pkgs.mkShell {
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

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          systemPackages = packagesFor.${system};
        in {
          default = pkgs.stdenv.mkDerivation rec {
            name = "expidus-sdk";
            src = self;

            setupHooks = [ ./setup-hook.sh ];

            enableParallelBuilding = true;
            inherit (systemPackages) nativeBuildInputs buildInputs;

            meta = with pkgs.lib; {
              homepage = "https://github.com/ExpidusOS/sdk";
              license = with licenses; [ gpl3Only ];
              maintainers = with lib.maintainers; [ TheComputerGuy ];
            };
          };
        });

      legacyPackages = forAllSystems (system: import ./pkgs { inherit system; });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          systemPackages = packagesFor.${system};
          sdk-pkg = packages.${system}.default;
        in {
          default = pkgs.mkShell {
            packages = systemPackages.nativeBuildInputs ++ systemPackages.buildInputs;
          };

          wrapped = pkgs.mkShell {
            packages = [ sdk-pkg ];
          };
        });
    };
}
