{
    lib,
    stdenv,
    fetchFromGitLab,
    beamPackages,
    npmlock2nix
}:
    let
      mixNixDeps = import ./../deps.nix { inherit lib beamPackages overrides; };

        overrides = (final: prev: {
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
          version = "0.0.1";

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
      });
    in beamPackages.mixRelease rec {
        pname = "kazarma";
        src = ../.;
        inherit mixNixDeps;
        version = "0.0.0";
        MIX_DEBUG=1;

        LANG = "en_US.UTF-8";
        LANGUAGE = "en_US:en";
        LC_ALL = "en_US.UTF-8";

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
            mix do deps.loadpaths --no-deps-check, phx.digest
            ln -s /app "$out"
        '';
    }