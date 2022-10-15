{
  description = "SDK for ExpidusOS";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      lib = import ./lib/default.nix;

      packagesFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in with pkgs; {
          nativeBuildInputs = [ meson ninja pkg-config ];
          buildInputs = [ uncrustify clang_14 ];
        });
    in rec {
      lib = lib.expidus;

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
