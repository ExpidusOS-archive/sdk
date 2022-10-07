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

      packagesFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in with pkgs; {
          nativeBuildInputs = [ meson ninja pkg-config ];
          buildInputs = [ uncrustify clang_14 ];
        });
    in rec {
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
          };
        });

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
