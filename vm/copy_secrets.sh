#!/usr/bin/env bash

# inspired by github.com/mitchellh/nixos-config

# Connectivity info for Linux VM
NIXADDR="${NIXADDR:-unset}"
NIXPORT="${NIXPORT:=22}"
NIXUSER="${NIXUSER:=michaelr}"

SSH_OPTIONS="-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

path_to_script=$(dirname "$(realpath $0)") 
path_to_dotfiles=$(dirname "$path_to_script")

rsync -av -e "ssh $SSH_OPTIONS -p$NIXPORT" \
    --exclude='environment' \
    $HOME/.ssh/ $NIXUSER@$NIXADDR:~/.ssh

