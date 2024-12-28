{
  description = "Simple static web server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      projectName = "stws";

      overlay = finalPkgs: prevPkgs:
        let
          prevHaskell = prevPkgs.haskell;
          justStaticExecutables = finalPkgs.haskell.lib.justStaticExecutables;
        in
        {
          haskell = prevHaskell // (
            let
              prevPackageOverrides = prevHaskell.packageOverrides;
              composeExtensions = finalPkgs.lib.composeExtensions;
            in
            {
              packageOverrides = composeExtensions prevPackageOverrides (final: _prev: {
                # Note: callCabal2nix calls cabal2nix and then callPackage on the result
                ${projectName} = final.callCabal2nix projectName ./. { };

                # Note: Use callPackage if already has nix file (e.g. obtained with cabal2nix)
                # project = final.callPackage ./project.nix { };
              });
            }
          );

          # To set specific ghc version:
          # haskellPackages = finalPkgs.haskell.packages.ghc864

          # Note: The key here can be different from projectName
          ${projectName} = justStaticExecutables finalPkgs.haskellPackages.${projectName};
        };

      forSystem = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
            config = { allowUnfree = true; };
          };

          pkg = pkgs.${projectName};

          devShell = pkgs.haskellPackages.shellFor {
            withHoogle = true;

            # Note: p is haskellPackages here
            packages = p: [
              p.${projectName}
            ];

            # Note: Use "buildInputs" for libs to link with (e.g. openssl, target arch)

            # build time tools (build arch)
            nativeBuildInputs = with pkgs.haskellPackages; [
              cabal-gild
              cabal-install
              haskell-language-server
              hlint
              ormolu
              weeder
            ];
          };
        in
        {
          # Note: Can use "apps" for "nix run" but it also falls back to "packages"

          # for "nix build"
          packages = {
            ${projectName} = pkg;
            default = pkg;
          };

          # for "nix develop"
          devShells = {
            ${projectName} = devShell;
            default = devShell;
          };
        };
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" ] forSystem;

  nixConfig = {
    # sets dev shell prompt (otherwise it's not clear you're in a shell)
    bash-prompt = "\\[\\e[1;34m\\][shell:\\W]\\$\\[\\e[0m\\] ";
  };
}
