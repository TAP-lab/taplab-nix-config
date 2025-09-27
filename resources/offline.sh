# Ensure correct directory
cd ~/.local/share/PrismLauncher/

# Copy accounts.json_ORIGINAL to accounts.json
cp accounts.json_ORIGINAL accounts.json

# Fix gui rendering issues
export GDK_BACKEND=x11

# Prompt user for a name using Zenity GUI
input_name=$(zenity --entry --title="Enter Your Username" --text="Username:")

# Replace CHANGETHISNAME with the inputted name in accounts.json
sed -i "s/CHANGETHISNAME/$input_name/g" accounts.json

# Won't launch if prism is open
pkill prismlauncher

# Launch game and connect to server
prismlauncher -l taplab -a $input_name -s SurvivalLAB.exaroton.me