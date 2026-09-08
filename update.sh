#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Always run relative to the script's directory
cd "$(dirname "$0")"

echo ":: Fetching latest flake inputs..."
nix flake update

echo ":: Rebuilding system configuration.."
sudo nixos-rebuild switch --flake .#nixie
