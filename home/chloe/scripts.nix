{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Convert nix hash to SRI format and fetch from URL
    (writeShellScriptBin "shash" ''
      nix hash to-sri --type sha256 $(nix-prefetch-url ''$1)
    '')

    # Create a Python virtual environment with --copies flag
    (writeShellScriptBin "create-venv" ''
      nix run nixpkgs#python3 -- -m venv .venv --copies
    '')

    # Run agenix in the secrets directory with a given secret file
    (writeShellScriptBin "secret" ''
      set -e
      if [ -z "$1" ]; then
        echo "usage: $0 <secret-file.age>"
        exit 1
      fi
      cd "$HOME/.config/flake/secrets"
      agenix -e "$1" -i ~/.ssh/id_ed25519.age
    '')
  ];
}
