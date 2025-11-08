# Nix Flake Usage Guide

This project is now available as a Nix flake, providing declarative dependency management and easy access to core functionalities through Nix apps.

## Prerequisites

- Nix with flakes enabled (Nix 2.4+)
- Enable flakes by adding to `~/.config/nix/nix.conf`:
  ```
  experimental-features = nix-command flakes
  ```

## Available Apps

### 1. Main Tutorial Generator

Generate AI-powered tutorials from codebases:

```bash
# Run directly from GitHub
nix run github:lessuselesss/PocketFlow-KB-flake -- --help

# Analyze a GitHub repository
nix run github:lessuselesss/PocketFlow-KB-flake -- \
  --repo https://github.com/username/repo \
  --include "*.py" "*.js" \
  --exclude "tests/*" \
  --max-size 50000

# Analyze a local directory
nix run github:lessuselesss/PocketFlow-KB-flake -- \
  --dir /path/to/your/codebase \
  --include "*.py" \
  --exclude "*test*"

# Generate tutorial in a different language
nix run github:lessuselesss/PocketFlow-KB-flake -- \
  --repo https://github.com/username/repo \
  --language "Chinese"
```

### 2. LLM Configuration Tester

Test your LLM setup before running the main application:

```bash
nix run github:lessuselesss/PocketFlow-KB-flake#test-llm
```

## Using Locally

If you've cloned the repository:

```bash
# Run main app
nix run . -- --help

# Run LLM tester
nix run .#test-llm

# Enter development shell
nix develop
```

## Development Shell

Enter a development environment with all dependencies:

```bash
nix develop
```

This provides:
- Python 3 with all required packages
- Git
- Direct access to source files

Once in the shell, you can run:
```bash
python main.py --help
python utils/call_llm.py
```

## Environment Variables

The application requires API keys. You can provide them via:

1. A `.env` file in the project directory:
   ```bash
   GEMINI_API_KEY=your_key_here
   GITHUB_TOKEN=your_token_here
   ```

2. Environment variables when running:
   ```bash
   GEMINI_API_KEY=xxx nix run . -- --repo https://github.com/user/repo
   ```

3. For alternative LLM providers, set:
   ```bash
   LLM_PROVIDER=XAI
   XAI_MODEL=your-model
   XAI_URL=your-api-url
   XAI_API_KEY=your-key
   ```

## Building the Package

Build the package locally:

```bash
nix build
./result/bin/pocketflow-kb --help
```

## Command Line Options

- `--repo` or `--dir` - GitHub repo URL or local directory (required)
- `-n, --name` - Project name (optional)
- `-t, --token` - GitHub token (or use GITHUB_TOKEN env var)
- `-o, --output` - Output directory (default: ./output)
- `-i, --include` - File patterns to include
- `-e, --exclude` - File patterns to exclude
- `-s, --max-size` - Maximum file size in bytes (default: 100KB)
- `--language` - Tutorial language (default: english)
- `--max-abstractions` - Max abstractions to identify (default: 10)
- `--no-cache` - Disable LLM caching

## Examples

Generate a tutorial for a Python project:
```bash
nix run . -- \
  --repo https://github.com/psf/requests \
  --include "*.py" \
  --exclude "tests/*" "docs/*" \
  --output ./tutorials/requests
```

Test with local codebase:
```bash
nix run . -- \
  --dir ~/projects/my-app \
  --language "Spanish" \
  --max-abstractions 5
```

## Troubleshooting

If you encounter issues:

1. Test your LLM configuration first:
   ```bash
   nix run .#test-llm
   ```

2. Ensure API keys are properly set in `.env` or environment

3. For private repositories, provide a GitHub token:
   ```bash
   nix run . -- --repo https://github.com/user/private-repo --token YOUR_TOKEN
   ```

## Integration with Other Tools

### direnv

Create a `.envrc` file:
```bash
use flake
```

This automatically loads the development environment when entering the directory.

### Home Manager

Add to your home.nix:
```nix
{
  home.packages = [
    (pkgs.callPackage (builtins.getFlake "github:lessuselesss/PocketFlow-KB-flake") {})
  ];
}
```
