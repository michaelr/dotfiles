{ writeShellScriptBin }:
let
  setDefaultBashAttrs = "set -eou pipefail";
in
[
  (writeShellScriptBin "dvt" ''
    ${setDefaultBashAttrs}

    if [ -z "''${1-}" ]; then
      echo "Error! usage: dvt template"
      echo ""
      dvts
      exit 1
    fi

    nix flake init -t "github:michaelr/my-dev-templates#$1"
    direnv allow 
  '')

  (writeShellScriptBin "dvts" ''
    ${setDefaultBashAttrs}

    echo "Available templates:"
    nix flake show --json "github:michaelr/my-dev-templates" | \
      jq '.templates | to_entries | .[] | .key + " - " + .value.description'
  '')

  (writeShellScriptBin "xrandr-print-output" ''
    ${setDefaultBashAttrs}

     xrandr | grep connected | grep -v disconnected | awk '{printf "%s", $1}'
  '')

  (writeShellScriptBin "project-session" ''
     if [ $# -ne 1 ]; then
        echo "Error: Not enough arguments";
        echo "Usage: $(basename $0) <dir>";
        exit 1;
    fi

    directory=$1

    mkdir -p $directory \
        && tmux new -c $directory -s $directory -d \
        && tmux switch -t $directory 
  '')

]
