# Caddy Development Scripts

This directory contains a utility script for managing Caddy plugins and builds in a Nix environment.

## Script

### `update_caddy_plugins.py`

A comprehensive script that combines the functionality of updating Go pseudo-versions and fixing Nix hashes to automatically update Caddy plugins to their latest versions.

**Features:**

- Automatically detects and updates all Caddy plugins to their latest versions
- Fixes Nix hash mismatches automatically
- Supports dry-run mode to preview changes
- Handles both direct Git repositories and vanity import paths
- Provides detailed logging and progress information

**Usage:**

```bash
# Update all plugins to latest versions
./update_caddy_plugins.py

# Preview what would be updated (dry-run)
./update_caddy_plugins.py --dry-run

# Force rebuild even if no updates are found
./update_caddy_plugins.py --force

# Enable verbose logging
./update_caddy_plugins.py --verbose

# Use a specific file path
./update_caddy_plugins.py --file /path/to/default.nix
```

**Options:**

- `--dry-run, -n`: Show what would be updated without making changes
- `--force, -f`: Force rebuild even if no updates are found
- `--verbose, -v`: Enable detailed logging
- `--file FILE`: Path to caddy-with-plugins/default.nix file (auto-detected if not specified)

## Workflow

The typical workflow for updating Caddy plugins is:

1. **Check current status**: Run `update_caddy_plugins.py --dry-run` to see if any updates are available
1. **Update plugins**: Run `update_caddy_plugins.py` to update all plugins and fix hashes
1. **Verify build**: The script automatically builds and fixes any hash mismatches

## File Structure

The scripts expect the following structure:

```
packages/
├── caddy-with-plugins/
│   └── default.nix          # Caddy configuration with plugins list
└── ...
```

The `default.nix` file should contain a structure like:

```nix
{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250622022107-8471c72ed5ea"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
  ];
  hash = "sha256-Qkxsas7IfAb+Y+i+YJ4TpchuuzMLppNFYriizxNS2KE=";
}
```

## Requirements

- Python 3.6+
- Git
- Nix with flakes support
- Internet access for fetching repository information

## Error Handling

The scripts include comprehensive error handling:

- Network timeouts when fetching repository information
- Git clone failures
- Nix build failures
- File parsing errors
- Hash extraction failures

If the main script fails, it will restore the original file to prevent leaving the system in a broken state.
