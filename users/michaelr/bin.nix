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

]
