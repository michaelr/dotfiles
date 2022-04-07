#!/usr/bin/env bash

set -eou pipefail

if [ $# -ne 1 ]; then
    echo "Error: Not enough arguments";
    echo "Usage: $(basename $0) <dir>";
    exit 1;
fi

directory=$1

mkdir -p $directory \
    && tmux new -c $directory -s $directory -d \
    && tmux switch -t $directory
