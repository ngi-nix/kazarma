{
    lib,
    stdenv,
    fetchFromGitLab,
    writeText,
    beamPackages,
    npmlock2nix,
    nodePackages, 
    elixir
}:
    let
      mixNixDeps = import ./deps.nix { inherit lib beamPackages overrides; };
        npm = nodePackages.npm;
        overrides = (final: prev: {
          mime = prev.mime.override {
          patchPhase =
            let
              cfgFile = writeText "config.exs" ''
                use Mix.Config
                config :mime, :types, %{
                  "application/xml" => ["xml"],
                  "application/xrd+xml" => ["xrd+xml"],
                  "application/jrd+json" => ["jrd+json"],
                  "application/activity+json" => ["activity+json"],
                  "application/ld+json" => ["activity+json"]
                  }
              '';
            in
            ''
              mkdir config
              cp ${cfgFile} config/config.exs
            '';
        };
        # mix2nix does not support git dependencies yet,
        # so we need to add them manually
        polyjuice_util = beamPackages.buildMix rec {
          name = "polyjuice_util";
          version = "0.2.1";
  
          src = beamPackages.fetchHex {
            pkg = "${name}";
            version = "${version}";
            sha256 = "sha256-lzu11yO2CURSknZCj7AJWw8hZex8CeEFfSxqb9OfDl0=";
          };
  
          beamDeps = with final; [ uuid jason ];
        };
  
        polyjuice_client = beamPackages.buildMix rec {
          name = "polyjuice_client";
          version = "0.4.2";
  
          src = fetchFromGitLab {
            domain = "gitlab.com";
            owner = "kazarma";
            repo = "polyjuice_client";
            rev = "ca8749c91a31f2b16202bc0ceffd4f2a07729f52";
            sha256 = "sha256-jPfko7+g2iHD+Tb6yjJl8IWRhzauAEmhyM+BQ1RFcmM=";
          };
          beamDeps = with final; [ hackney poison polyjuice_util ];
        };

        http_signatures = beamPackages.buildMix rec {
          name = "http_signatures";
          version = "0.1.0";

          src = fetchFromGitLab {
            domain = "git.pleroma.social";
            group = "pleroma";
            owner = "elixir-libraries";
            repo = "http_signatures";
            rev = "293d77bb6f4a67ac8bde1428735c3b42f22cbb30";
            sha256 = "sha256-pLeuLPBuW5BrvmCwbfZDLpQtq2iji+mDNeBAyLwSuBM=";
          };
          preBuild = ''
            substituteInPlace mix.exs --replace "extra_applications: [:logger]" "extra_applications: [:logger, :public_key]"
          '';
          beamDeps = [ ];
        };

        activity_pub = beamPackages.buildMix rec {
          name = "activity_pub";
          version = "0.1.0";

          src = fetchFromGitLab {
            domain = "gitlab.com";
            owner = "kazarma";
            repo = "ActivityPub";
            rev = "56eeab2270fd271e6388fa3071d8b240acb6c249";
            sha256 = "sha256-j7axNibC6LQI7pWGiSP5H2w4dTUJmiXmqPxfYsVlLXs=";
          };

          preBuild = '' 
            export DATABASE_URL=$DATABASE_URL
            export SECRET_KEY_BASE=$SECRET_KEY_BASE
          '';

          beamDeps = with final; [ phoenix phoenix_ecto ecto_sql postgrex phoenix_live_dashboard telemetry gettext jason plug_cowboy oban hackney tesla http_signatures pointers pointers_ulid ];
        };

        matrix_app_service = beamPackages.buildMix {
          name = "matrix_app_service";
          version = "0.1.0";

          src = fetchFromGitLab {
            domain = "gitlab.com";
            owner = "kazarma";
            repo = "matrix_app_service.ex";
            rev = "de037620455e5c05d7dac4e1cb8609e78dd7f15e";
            sha256 = "sha256-l8eCJ5mcCE4pwdJYwVKMrI2PBtW8AcVCo8lJ+W9nI2E=";
            };

          beamDeps = with final; [ phoenix phoenix_ecto ecto_sql postgrex telemetry plug_cowboy jason polyjuice_client  ];
        };
      });
    in beamPackages.mixRelease rec {
        pname = "kazarma";
        src = ../.;
        inherit mixNixDeps;
        version = "0.1.0";
        MIX_DEBUG=1;

        LANG = "en_US.UTF-8";
        LANGUAGE = "en_US:en";
        LC_ALL = "en_US.UTF-8";

        nativeBuildInputs = [ elixir ];

        node_modules = npmlock2nix.node_modules {
          src = ../assets;
        };

        postConfigure = ''
            rm _build/prod/lib/ex_cldr
            mkdir -p _build/prod/lib/ex_cldr/priv/cldr/locales
            cp -r ${mixNixDeps.ex_cldr}/lib/erlang/lib/ex_cldr-2.23.2/* _build/prod/lib/ex_cldr
        '';

        postBuild = ''
            ln -sf ${node_modules}/node_modules assets/node_modules
            ${npm}/bin/npm run deploy --prefix ./assets
            mix do deps.loadpaths --no-deps-check, phx.digest
        '';

        postInstall = ''
            echo "${beamPackages.erlang.version}" > $out/OTP_VERSION
        '';
    }