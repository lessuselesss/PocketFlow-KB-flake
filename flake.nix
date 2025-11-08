{
  description = "PocketFlow Codebase Knowledge - AI-powered codebase tutorial generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Build pocketflow from PyPI
        pocketflow = pkgs.python3.pkgs.buildPythonPackage rec {
          pname = "pocketflow";
          version = "0.0.1";
          format = "wheel";
          src = pkgs.python3.pkgs.fetchPypi {
            inherit pname version format;
            dist = "py3";
            python = "py3";
            sha256 = "sha256-WC+5/aeNzIr+qgCrQ7iRqPnmYZfYJhKbMgLp9ItzWvc=";
          };
          doCheck = false;
          propagatedBuildInputs = [ ];
        };

        # Build google-genai from PyPI
        google-genai = pkgs.python3.pkgs.buildPythonPackage rec {
          pname = "google-genai";
          version = "1.9.0";
          format = "wheel";
          src = pkgs.python3.pkgs.fetchPypi {
            inherit pname version format;
            dist = "py3";
            python = "py3";
            sha256 = "sha256-2YQMeXFMUvVXO4rXKVs9pU5J9JjH3G0X2wVKkqXYqHk=";
          };
          doCheck = false;
          propagatedBuildInputs = with pkgs.python3.pkgs; [
            google-api-core
            google-auth
            protobuf
            requests
          ];
        };

        # Python environment with all dependencies
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          pyyaml
          requests
          gitpython
          google-cloud-aiplatform
          python-dotenv
          pathspec
          pocketflow
          google-genai
        ]);

        # Main PocketFlow KB package
        pocketflow-kb-package = pkgs.stdenv.mkDerivation {
          name = "pocketflow-kb";
          src = self;

          buildInputs = [ pythonEnv ];

          installPhase = ''
            mkdir -p $out/share/pocketflow-kb
            cp -r * $out/share/pocketflow-kb/

            mkdir -p $out/bin

            # Create wrapper script for main application
            cat > $out/bin/pocketflow-kb << 'EOF'
            #!${pkgs.bash}/bin/bash
            cd $out/share/pocketflow-kb
            exec ${pythonEnv}/bin/python main.py "$@"
            EOF
            chmod +x $out/bin/pocketflow-kb

            # Create wrapper script for LLM testing
            cat > $out/bin/pocketflow-kb-test-llm << 'EOF'
            #!${pkgs.bash}/bin/bash
            cd $out/share/pocketflow-kb
            exec ${pythonEnv}/bin/python utils/call_llm.py "$@"
            EOF
            chmod +x $out/bin/pocketflow-kb-test-llm
          '';
        };

      in
      {
        packages = {
          default = pocketflow-kb-package;
          pocketflow-kb = pocketflow-kb-package;
        };

        apps = {
          default = {
            type = "app";
            program = "${pocketflow-kb-package}/bin/pocketflow-kb";
          };

          pocketflow-kb = {
            type = "app";
            program = "${pocketflow-kb-package}/bin/pocketflow-kb";
          };

          test-llm = {
            type = "app";
            program = "${pocketflow-kb-package}/bin/pocketflow-kb-test-llm";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.git
          ];

          shellHook = ''
            echo "PocketFlow Codebase Knowledge Development Environment"
            echo ""
            echo "Available commands:"
            echo "  python main.py --help     - Run the tutorial generator"
            echo "  python utils/call_llm.py  - Test LLM configuration"
            echo ""
            echo "Make sure to set up your .env file with API keys:"
            echo "  GEMINI_API_KEY=your_key_here"
            echo "  GITHUB_TOKEN=your_token_here (optional)"
          '';
        };
      }
    );
}
