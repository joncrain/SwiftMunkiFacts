#!/bin/zsh

# Grab the list of plugins from current directory
plugins=(*Plugin)
destination="/Library/MunkiFacts/Plugins"

# Loop through each plugin and refresh it
for plugin in "${plugins[@]}"; do
    echo "Refreshing $plugin..."
    plugin_name=(${plugin//Plugin/})
    if [[ "$1" != "skip" ]]; then
        cd "$plugin" && swift package clean && swift build -c release && cd ..
    fi
    # Copy plugin to destination
    cp -R "./$plugin/.build/release/lib${plugin}.dylib" "$destination/${plugin_name}.plugin"
done