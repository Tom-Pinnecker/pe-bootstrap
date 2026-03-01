#!/usr/bin/env bash
# Bootstrap installer
# Copyright (c) 2026 Pinnecker Engineering
# Licensed under the MIT License. See LICENSE file for details.

set -e

# Determine which user owns the home directory
BOOTSTRAP_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$BOOTSTRAP_USER")


echo "==============================================================="
echo "Updating system..."
echo "==============================================================="
apt update && apt upgrade -y


echo "==============================================================="
echo "Installing Git..."
echo "==============================================================="
apt install -y git


echo "==============================================================="
echo "Preparing SSH..."
echo "==============================================================="
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"

KEY_FILE="$USER_HOME/.ssh/github_deploy_key"

if [ ! -f "$KEY_FILE" ]; then
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "bootstrap deploy key"
    chown "$BOOTSTRAP_USER":"$BOOTSTRAP_USER" "$KEY_FILE" "$KEY_FILE.pub"
fi

CONFIG_BLOCK="
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_deploy_key
"

if ! grep -q "$KEY_FILE" "$USER_HOME/.ssh/config" 2>/dev/null; then
    echo "$CONFIG_BLOCK" >> "$USER_HOME/.ssh/config"
    chown "$BOOTSTRAP_USER":"$BOOTSTRAP_USER" "$USER_HOME/.ssh/config"
    chmod 600 "$USER_HOME/.ssh/config"
fi


echo "==============================================================="
echo "✅ Bootstrap complete."
echo "Add the ssh-pub-key to your Repository → Settings → Deploy Keys"
echo ""
cat $USER_HOME/.ssh/github_deploy_key.pub
echo ""
echo "==============================================================="
