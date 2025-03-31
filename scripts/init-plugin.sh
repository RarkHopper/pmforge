#!/bin/bash
set -e

prompt() {
  read -r -p "$1: " value
  eval "$2=\$value"
}

# Gather plugin information
prompt "Plugin Name" plugin_name
prompt "Version (e.g., 1.0.0)" version
prompt "Author" author
prompt "Description" description
prompt "Main Class (e.g., MyPlugin)" main_class

# Sanitize plugin name for directory creation (replace spaces with underscores, remove special characters)
plugin_name_sanitized=$(echo "$plugin_name" | tr ' ' '_' | sed 's/[^a-zA-Z0-9_]//g')

# Create the plugin directory structure
mkdir -p "src/$author/$plugin_name_sanitized"

# Create the main class file (empty)
touch "src/$author/$plugin_name_sanitized/$main_class.php"

# Create the plugin.yml file in the root directory
cat > plugin.yml <<EOL
name: $plugin_name
version: $version
api: ["5.0.0"] # Adjust API version as needed
author: $author
description: $description
main: $author\\$plugin_name_sanitized\\$main_class
EOL

echo "Plugin project initialized."
echo "plugin.yml created in the root directory."
echo "Main class directory: src/$author/$plugin_name_sanitized/$main_class.php"
