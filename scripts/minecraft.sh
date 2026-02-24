#!/usr/bin/env bash

# Ensures it is working in the correct directory
cd ~/.local/share/PrismLauncher/

# Copies accounts.json_ORIGINAL to accounts.json to reset any previous changes
cp accounts.json_ORIGINAL accounts.json

# Fixes rendering issues with zenity on Wayland by forcing X11
export GDK_BACKEND=x11

# Prompts user for a name using a Zenity GUI
input_name=$(zenity --entry --title="Enter Your Username" --text="Username:")

# If user cancels, exit
if [[ $? -ne 0 ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Replaces CHANGETHISNAME with the inputted name in accounts.json
sed -i "s/CHANGETHISNAME/$input_name/g" accounts.json

# Launches game and automatically connects to the TAPLab server
prismlauncher -l taplab -a $input_name -s 10.0.0.181 &

