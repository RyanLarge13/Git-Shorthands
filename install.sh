#!/bin/bash

INSTALL_PATH="/usr/local/bin/gs"

sudo ln -sf "$(pwd)/gs" "$INSTALL_PATH"
echo "Installed gs to $INSTALL_PATH"

# Install autocomplete
mkdir -p ~/.local/share/bash-completion/completions
cp ./gs_completion ~/.local/share/bash-completion/completions/gs

echo "Autocomplete installed."