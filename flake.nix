{
  description = "A Matrix bridge to ActivityPub.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs?ref=master;
    utils.url = "github:numtide/flake-utils";
    npmlock2nix = { url = "github:nix-community/npmlock2nix"; flake = false; };
  };

  outputs = { self, nixpkgs, utils, npmlock2nix }:
    let
    pkgsForSystem = system: import nixpkgs {
        overlays = [ npmlock2nixOverlay overlay ];
        inherit system;
      };

    npmlock2nixOverlay = final: prev: {
      npmlock2nix = import npmlock2nix { pkgs = final; };
    };

    overlay = final: prev: rec {
      beamPackages = prev.beam.packagesWith prev.beam.interpreters.erlangR24;
      elixir = prev.beam.interpreters.elixir_1_11;
      kazarma = prev.callPackage ./nix/kazarma.nix { inherit beamPackages elixir; };
    };
    in utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-linux"] (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) kazarma;
      };
      defaultPackage = packages.kazarma;
      devShell = self.devShells.${system}.dev;
      devShells = {
        dev = import ./nix/shell.nix {
          pkgs = legacyPackages;
          db_name = "kazarma_dev";
          MIX_ENV = "dev";
        };
        test = import ./nix/shell.nix {
          pkgs = legacyPackages;
          db_name = "kazarma_test";
          MIX_ENV = "test";
        };
        prod = import ./nix/shell.nix {
          pkgs = legacyPackages;
          db_name = "kazarma_prod";
          MIX_ENV = "prod";
        };
      };
      apps.kazarma = utils.lib.mkApp { drv = packages.kazarma; };
      hydraJobs = { inherit (legacyPackages) kazarma; };
      checks = { inherit (legacyPackages) kazarma; };
      nixosModules.kazarma =
        { lib, config, ... }:
            with lib;
            let
              cfg = config.services.kazarma;
            in {
              config = mkIf cfg.enable {
                    nixpkgs.overlays = [ self.overlay ];

                    systemd.packages = [ defaultPackage ];

                    systemd.services.kazarma = {
                      path = [ defaultPackage ];
                      description = "Kazarma, a Matrix-ActivityPub bridge service.";

                      serviceConfig = {
                        Type = "simple";
                        ExecStart = "${defaultPackage}/bin/kazarma daemon";
                        wantedBy = [ "default.target" ];
                      };
                    };
              };
            };
    }) // { overlay = overlay ;};
}
