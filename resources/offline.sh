# Ensures it is working in the correct directory
cd ~/.local/share/PrismLauncher/

# Copies accounts.json_ORIGINAL to accounts.json to reset any previous changes
cp accounts.json_ORIGINAL accounts.json

# Fixes rendering issues with zenity on Wayland by forcing X11
export GDK_BACKEND=x11

# Prompts user for a name using a Zenity GUI
input_name=$(zenity --entry --title="Enter Your Username" --text="Username:")

# Replaces CHANGETHISNAME with the inputted name in accounts.json
sed -i "s/CHANGETHISNAME/$input_name/g" accounts.json

# Kills any running instance of prism launcher otherwise the game does not launch
pkill prismlauncher

# Launches game and automatically connects to the TAPLab server
prismlauncher -l taplab -a $input_name -s SurvivalLAB.exaroton.me &

# Waits for the Prism window to appear and then closes it
while true; do      # Loop indefinitely
    win_id=$(kdotool getactivewindow)       # Gets the ID of the currently active window
    win_name=$(kdotool getwindowname "$win_id")         # Gets the name of the window with that ID
    if [[ "$win_name" == *Prism* ]]; then       # Checks if the window name contains "Prism"
        # If true, it closes the window using a KDE global shortcut
        qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut "Window Close"
        break       # Exit the loop after closing the window
    fi
    sleep 0.1       # Loops the check every 0.1 seconds (10x per second)
done
