#!/usr/bin/env bash

# Ensures it is working in the correct directory
cd ~/.local/share/PrismLauncher/

# Copies accounts.json_ORIGINAL to accounts.json to reset any previous changes
cp accounts.json_ORIGINAL accounts.json

# Fixes rendering issues with zenity on Wayland by forcing X11
export GDK_BACKEND=x11

# Prompts user for a name using a Zenity GUI
input_name=$(zenity --entry --title="Enter Your Username" --text="Username:")

if [[ $? -ne 0 ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Replaces CHANGETHISNAME with the inputted name in accounts.json
sed -i "s/CHANGETHISNAME/$input_name/g" accounts.json

# Builds list of available PrismLauncher instances
instances_dir="$HOME/.local/share/PrismLauncher/instances"
instance_list=()
while IFS= read -r -d '' dir; do
    instance_list+=("$(basename "$dir")")
done < <(find "$instances_dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ ${#instance_list[@]} -eq 0 ]]; then
    zenity --error --title="No Instances Found" --text="No PrismLauncher instances were found in:\n$instances_dir"
    exit 1
fi

# Move preferred default instance to the top of the list
default_instance="taplab"
if [[ " ${instance_list[*]} " == *" $default_instance "* ]]; then
    instance_list=("$default_instance" $(printf '%s\n' "${instance_list[@]}" | grep -v "^${default_instance}$"))
fi

# Prompts user to pick an instance from a dropdown
selected_instance=$(zenity --list \
    --title="Select Instance" \
    --text="Choose a PrismLauncher instance:" \
    --column="Instance" \
    --height=300 \
    "${instance_list[@]}")

if [[ $? -ne 0 || -z "$selected_instance" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Launches the selected instance and automatically connects to the TAPLab server
prismlauncher -l "$selected_instance" -a "$input_name" -s 10.5.0.200 &
