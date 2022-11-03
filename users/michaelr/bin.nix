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

    # use basename as session name and remove
    # any . chars because tmux can't use them
    session=$(basename $directory | sed 's/\.//g')


    # create session if it doesn't exist
    if ! tmux has-session -t "$session" 2> /dev/null; then
      TMUX="" tmux new-session -c $directory -s "$session" -d 'nvim'
    fi

    # attach if outside tmux, switch if inside
    if [[ -z "''${TMUX-}" ]]; then
      tmux attach -t "$session"
    else
      tmux switch-client -t "$session"
    fi

  '')

  # select project directory to open/start tmux session
  (writeShellScriptBin "p" ''
    ${setDefaultBashAttrs}

    project-session $(\
      fd -H -td '^\.git$' -tf --search-path ~/code -x echo {//} \
      | fzf \
    )
  '')

  (writeShellScriptBin "send-mail-to-obsidian" ''
    ${setDefaultBashAttrs}

    message_path=$(</dev/stdin)
    obsidian_file="/home/michaelr/code/personal/mrkdwn/inbox/TMFMInbox.md"
    parsed_mail=$(echo $message_path | parse-to-me-from-me-mail)

    echo "$parsed_mail" >> "$obsidian_file"
  '')
]
