#!/usr/bin/env bash

# inspired by github.com/mitchellh/nixos-config

# Connectivity info for Linux VM
NIXADDR="${NIXADDR:-unset}"
NIXPORT="${NIXPORT:=22}"

SSH_OPTIONS="-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

path_to_script=$(dirname "$(realpath $0)") 
path_to_dotfiles=$(dirname "$path_to_script")

rsync -av -e "ssh $SSH_OPTIONS -p$NIXPORT" \
    --exclude='.git/' \
    --rsync-path="sudo rsync" \
    $path_to_dotfiles/ root@$NIXADDR:/root/nix-config

