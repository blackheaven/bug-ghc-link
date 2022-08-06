{
  description = "bug";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        github = owner: repo: rev: sha256:
          builtins.fetchTarball { inherit sha256; url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"; };

        sources = { };

        jailbreakUnbreak = pkg:
          pkgs.haskell.lib.doJailbreak (pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.unmarkBroken pkg));

        haskellPackages = pkgs.haskell.packages.ghc923.override {
          overrides = hself: hsuper:
            let
              pulsarHsSrc = github "hetchr" "pulsar-hs"
                "131052da2a59d5d67189905331df150403820bd1" "0nihb1gxy2dxspsyhihdrvxrylci50liq5lpkncz05r0z1bza0sk";
              pulsarHs = import "${pulsarHsSrc}/pulsar-client-hs" {
                nixpkgs = pkgs;
                compiler = "ghc923";
              };
            in
            {
              nfc = jailbreakUnbreak hsuper.nfc;
              polysemy = hsuper.polysemy_1_7_1_0;
              polysemy-plugin = hsuper.polysemy-plugin_0_4_3_1;
              type-errors = jailbreakUnbreak hsuper.type-errors;
              pulsar-client-hs = jailbreakUnbreak pulsarHs.pulsar-client-hs;
            };
        };
      in
      rec
      {
        packages.bug = # (ref:haskell-package-def)
          haskellPackages.callCabal2nix "bug" ./. rec {
            # Dependency overrides go here
          };

        defaultPackage = packages.bug;

        devShell =
          let
            scripts = pkgs.symlinkJoin {
              name = "scripts";
              paths = pkgs.lib.mapAttrsToList pkgs.writeShellScriptBin { };
            };
          in
          pkgs.mkShell {
            buildInputs = with haskellPackages; [
              haskell-language-server
              ghcid
              cabal-install
              haskell-ci
              scripts
              ormolu
            ];
            inputsFrom = [
              self.defaultPackage.${system}.env
            ];
          };
      });
}
