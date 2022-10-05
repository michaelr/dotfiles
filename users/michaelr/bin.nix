{ writeScriptBin }:
[
  (writeScriptBin "dvt" ''
    nix flake init -t "github:michaelr/my-dev-templates#$1"
    direnv allow 
  '')

  (writeScriptBin "dvts" ''
    nix flake show --json "github:michaelr/my-dev-templates" | jq '.templates' 
  '')

]
