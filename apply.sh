#!/usr/bin/env bash

REPO_PATH="."

set -euo pipefail

if [ ! -d "$REPO_PATH/home" ]; then
  echo "Error: '$REPO_PATH/home' directory not found in repository."
  exit 1
fi

if [ ! -d "$REPO_PATH/nixos" ]; then
  echo "Error: '$REPO_PATH/nixos' directory not found in repository."
  exit 1
fi

# Create backup directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.nixos_config_backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR/home" "$BACKUP_DIR/nixos"

# Backup current configurations
echo "Creating backups in $BACKUP_DIR..."
rsync -av --exclude=".nixos_config_backups" --exclude=".cache" "$HOME/" "$BACKUP_DIR/home/"
sudo rsync -av "/etc/nixos/" "$BACKUP_DIR/nixos/"

# Sync repository files to system
echo "Syncing home configuration to $HOME..."
rsync -avh --exclude=".git" --exclude=".cache" "$REPO_PATH/home/" "$HOME/"

echo "Syncing nixos configuration to /etc/nixos/..."
sudo rsync -avh --exclude=".cache" "$REPO_PATH/nixos/" "/etc/nixos/"

# Run nswitchu to apply configuration
echo "Applying NixOS configuration with nswitchu..."
sudo nix flake update --flake /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#thor --upgrade

echo "NixOS configuration applied successfully!"
echo "Backups stored in: $BACKUP_DIR"
