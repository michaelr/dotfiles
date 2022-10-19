{ writeShellScriptBin }:
let
  setDefaultBashAttrs = "set -eou pipefail";
in
[
  # use a dev template
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

  # print available dev templates
  (writeShellScriptBin "dvts" ''
    ${setDefaultBashAttrs}

    echo "Available templates:"
    nix flake show --json "github:michaelr/my-dev-templates" | \
      jq '.templates | to_entries | .[] | .key + " - " + .value.description'
  '')

  # print the name of the current monitor as used by xrandr
  (writeShellScriptBin "xrandr-print-output" ''
    ${setDefaultBashAttrs}

     xrandr | grep connected | grep -v disconnected | awk '{printf "%s", $1}'
  '')

  # scale x session by zooming in
  (writeShellScriptBin "x-scale-zoom" ''
    xrandr --output $(xrandr-print-output) --scale 0.5
  '')

  # reset x scale to default
  (writeShellScriptBin "x-scale-reset" ''
    xrandr --output $(xrandr-print-output) --scale 1
  '')

  # start a tmux session in a directory
  (writeShellScriptBin "project-session" ''
    ${setDefaultBashAttrs}

     if [ $# -ne 1 ]; then
        echo "Error: Not enough arguments";
        echo "Usage: $(basename $0) <dir>";
        exit 1;
    fi

    directory=$1
    session=$(basename $directory)

    mkdir -p $directory \
        && tmux new -c $directory -s $session -d 'nvim' \
        && tmux attach -t $session
  '')

  # select project directory to open/start tmux session
  (writeShellScriptBin "p" ''
    ${setDefaultBashAttrs}

    fd -H -td '^\.git$' -tf --search-path ~/code -x echo {//} | \
      fzf | \
      xargs project-session
  '')
]
