{
    lib,
    stdenv,
    beamPackages,
    nodejs
}:
    let
      mixNixDeps = import ./../deps.nix { inherit lib beamPackages; };

      nodeDependencies = (lib.callPackage ./../assets/default.nix {}).shell.nodeDependencies;

      nodeAssets = stdenv.mkDerivation {
          name = "phoenix";
          src = ./../assets;
          buildInputs = [nodejs];
          preBuild = ''
            mkdir -p tmp/deps
            cp -r ${mixNixDeps}/phoenix tmp/deps/phoenix
            cp -r ${mixNixDeps}/phoenix_html tmp/deps/phoenix_html
          '';
          buildPhase = ''
            ln -s ${nodeDependencies}/lib/node_modules ./node_modules
            npm run deploy --prefix ./assets

            export PATH="${nodeDependencies}/bin:$PATH"
          '';
        };
    in beamPackages.mixRelease {
        pname = "kazarma";
        src = ../.;
        inherit mixNixDeps;
        version = "0.0.0";
        MIX_DEBUG=1;

        LANG = "en_US.UTF-8";
        LANGUAGE = "en_US:en";
        LC_ALL = "en_US.UTF-8";
        
        postBuild = ''
            mix do deps.loadpaths --no-deps-check, phx.digest
            ln -s /app "$out"
        '';
    }