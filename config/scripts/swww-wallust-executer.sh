#!/usr/bin/env bash

LAST_WALL=""

echo "LOG: Wallust Poller Started (20s Timeout Enabled)."

while true; do
    # Get current wallpaper path
    CURRENT_WALL=$(swww query | head -n 1 | sed 's/.*image: //' | xargs)

    if [[ "$CURRENT_WALL" != "$LAST_WALL" && -f "$CURRENT_WALL" ]]; then
        echo "LOG: New wallpaper detected: $CURRENT_WALL"
        
        # 20 second timeout for the wallust command
        # If wallust hangs, it will be killed and the script will continue
        if timeout 20s wallust run "$CURRENT_WALL"; then
            echo "LOG: Wallust finished successfully."
            # Only reload if wallust actually succeeded
            # quickshell --reload 

            kitty @ set-colors --all --configured ~/.config/kitty/colors.conf
            
        else
            echo "ERROR: Wallust timed out or failed after 20 seconds!"
        fi
        
        LAST_WALL="$CURRENT_WALL"
    fi
    
    sleep 1
done