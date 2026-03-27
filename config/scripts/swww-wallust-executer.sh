#!/usr/bin/env bash

LAST_WALL=""

echo "LOG: Wallust Poller Started. Checking for wallpaper changes every 1s..."

while true; do
    # 1. Get current wallpaper path safely from your specific swww output
    CURRENT_WALL=$(swww query | head -n 1 | sed 's/.*image: //' | xargs)

    # 2. Check if the path actually exists and is different from last time
    if [[ "$CURRENT_WALL" != "$LAST_WALL" && -f "$CURRENT_WALL" ]]; then
        echo "LOG: New wallpaper detected: $CURRENT_WALL"
        
        # 3. Run wallust
        wallust run "$CURRENT_WALL"
        
        # Update our tracker
        LAST_WALL="$CURRENT_WALL"
    fi
    
    # Wait 1 second before checking again (very low CPU usage)
    sleep 1
done