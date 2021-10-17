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
                    default = "127.0.0.1";
                    description = "the DB host name.";
                  };
                  socket_dir = mkOption {
                    type = types.str;
                    default = "/run/postgresql";
                    description = "DB socket directory.";
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
                localPostgres = (cfg.settings.database.socket_dir == "/run/postgresql" || cfg.settings.database.host == "localhost");
                
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
                  gen_key_base = ''
                    
                    mix phx.gen.secret > secret_key_base.txt
                  '';
                  serviceConfig = {
                    ExecStart = "${defaultPackage}/bin/kazarma daemon";
                    wantedBy = [ "multi-user.target" ];
                    LoadCredential = "secret_key_base:secret_key_base.txt";
                  };
                };
          };
        ## A VM test of the NixOS module.
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
        }