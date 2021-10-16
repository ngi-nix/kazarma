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
        { nixpkgs, lib, config, ... }:
            with lib;
            let
              cfg = config.services.kazarma;
            in {
              options.services.kazarma = {
                  enable = mkEnableOption "Enable Kazarma, a Matrix bridge to ActivityPub";
                  host = mkOption {
                    type = types.str;
                    default = "127.0.0.1";
                    description = "Host for the Kazarma application, used to generate URLs.";
                  };
                  secretKeyBase = mkOption {
                    type = types.str;
                    default = null;
                    description = "Phoenix's secret key base, used to sign session cookies. With Mix and Phoenix, it can be easily generated with mix phx.gen.secret.";
                  };
                  homeserverToken = mkOption {
                    type = types.str;
                    default = null;
                    description = "Token defined in the application service configuration file, will be used to authenticate the Matrix server against Kazarma.";
                  };
                  accessToken = mkOption {
                    type = types.str;
                    default = null;
                    description = "Token defined in the application service configuration file, will be used to authenticate Kazarma against the Matrix server.";
                  };
                  matrixUrl = mkOption {
                    type = types.str;
                    default = "https://127.0.0.1:8008/matrix/";
                    description = "URL to the Matrix server.";
                  };
                  activityPubDomain = mkOption {
                    type = types.str;
                    default = null;
                    description = "";
                  };
                  puppetPrefix = mkOption {
                    type = types.str;
                    default = "ap_";
                    description = "Username prefix for Matrix puppet users that correspond to ActivityPub real actors.";
                  };
                  bridgeRemote = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Whether Kazarma should bridge Matrix users from different homeservers (than the one beside Kazarma), to the ActivityPub network.";
                  };
                  htmlSearch = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Whether to show the search field on Kazarma HTML pages.";
                  };
                  htmlAP = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Whether to display profiles for ActivityPub actors. It can help Matrix users to get the (puppet) Matrix ID to reach an ActivityPub actor.";
                  };
                  database = {
                      user = mkOption {
                        type = types.str;
                        default = "kazarma";
                        description = "the DB user name.";
                      };
                      password = mkOption {
                        type = types.str;
                        default = "postgres";
                        description = "the DB password.";
                      };
                      host = mkOption {
                        type = types.str;
                        default = "/run/postgresql";
                        description = "the DB host name.";
                      };
                      name = mkOption {
                        type = types.str;
                        default = "kazarma";
                        description = "the DB name.";
                      };
                      createLocally = mkEnableOption "create the database on the instance";
                  };
                };

              config = mkIf cfg.enable {
                    nixpkgs.overlays = [ self.overlay ];

                    localPostgres = cfg.settings.database.socket_dir == "/run/postgresql"; # || cfg.settings.database.host == "localhost");
                    
                    services.postgresql = mkIf localPostgres {
                      enable = mkDefault true;
                    };

                    systemd.services = {
                        matrix-synapse.enable = true;
                        element-desktop.enable = true;                 
                        pleroma-otp.enable = true;
                        kazarma-postgresql = mkIf cfg.settings.database.createLocally {
                          description = "Kazarma postgresql db";
                          after = [ "postgresql.service" ];
                          bindsTo = [ "postgresql.service" ];
                          requiredBy = [ "kazarma.service" ];
                          partOf = [ "kazarma.service" ];
                          script = with cfg.settings.database; ''
                            PSQL() {
                              ${config.services.postgresql.package}/bin/psql --port=${toString cfg.settings.database.port} "$@"
                            }
                            # check if the database already exists
                            if ! PSQL -lqt | ${pkgs.coreutils}/bin/cut -d \| -f 1 | ${pkgs.gnugrep}/bin/grep -qw ${name} ; then
                              PSQL -tAc "CREATE ROLE ${user} WITH LOGIN;"
                              PSQL -tAc "CREATE DATABASE ${name} WITH OWNER ${user};"
                            fi
                          '';
                          serviceConfig = {
                            User = config.services.postgresql.superUser;
                            Type = "oneshot";
                            RemainAfterExit = true;
                            };
                          };

                      environment = {
                        HOMESERVER_TOKEN = cfg.homeserverToken;
                        ACCESS_TOKEN = cfg.accessToken;
                        MATRIX_URL = cfg.matrixUrl;
                        ACTIVITY_PUB_DOMAIN = cfg.activityPubDomain;
                        RELEASE_DISTRIBUTION = "none";
                        RELEASE_TMP = "tmp";
                      };

                      serviceConfig = {
                        ExecStart = "${defaultPackage}/bin/kazarma daemon";
                        wantedBy = [ "multi-user.target" ];
                      };
                    };
              };
              #   # A VM test of the NixOS module.
              vmTest =
                with import (nixpkgs + "/nixos/lib/testing-python.nix")
                  {
                    inherit system;
                  };

                makeTest {
                  nodes = {
                    client = { ... }: {
                      imports = [ self.nixosModules.kazarma ];
                    };
                  };

                  testScript =
                    ''
                      start_all()
                      client.wait_for_unit("default.target")
                      client.succeed("hello")
                    '';
                 };
            };
    }) // { overlay = overlay ;};
}
