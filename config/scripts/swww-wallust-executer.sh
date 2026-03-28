#!/usr/bin/env bash

# --- CONFIGURATION ---
LAST_WALL=""
CACHE_DIR="$HOME/.cache/wallust"
HISTORY_DIR="$CACHE_DIR/history"
KITTY_CONF="$HOME/.config/kitty/colors.conf"

# Ensure history directory exists
mkdir -p "$HISTORY_DIR"

echo "LOG: Wallust Poller Started with Caching."

while true; do
    # 1. Get current wallpaper path reliably
    CURRENT_WALL=$(swww query | head -n 1 | awk -F 'image: ' '{print $2}' | xargs)

    # 2. Check if wallpaper actually changed and exists
    if [[ "$CURRENT_WALL" != "$LAST_WALL" && -f "$CURRENT_WALL" ]]; then
        echo "LOG: Wallpaper change detected: $(basename "$CURRENT_WALL")"
        
        # 3. Create a unique fingerprint for this image
        WALL_ID=$(md5sum "$CURRENT_WALL" | cut -d' ' -f1)
        
        if [ -f "$HISTORY_DIR/$WALL_ID" ]; then
            echo "LOG: Cache Hit ($WALL_ID). Fast-applying templates..."
            
            # Restore the cached color sequences
            cp "$HISTORY_DIR/$WALL_ID" "$CACHE_DIR/sequences"
            
            # Use -s (skip) to skip image analysis but RE-GENERATE Theme.qml and kitty configs
            wallust run -s "$CURRENT_WALL"
            SUCCESS=true
        else
            echo "LOG: Cache Miss. Running full analysis (this may take a second)..."
            
            if timeout 20s wallust run "$CURRENT_WALL"; then
                # Backup the newly generated sequences for next time
                cp "$CACHE_DIR/sequences" "$HISTORY_DIR/$WALL_ID"
                SUCCESS=true
            else
                echo "ERROR: Wallust timed out or failed!"
                SUCCESS=false
            fi
        fi

        # 4. Apply changes to running applications
        if [ "$SUCCESS" = true ]; then
            echo "LOG: Applying colors to terminals and shell..."

            # Apply colors to all running Kitty instances
            if [ -f "$KITTY_CONF" ]; then
                kitty @ set-colors --all --configured "$KITTY_CONF"
            fi

            # Force your specific "Greyish/Black" glass overrides
            kitty @ set-colors --all "background=#2f2f2f"
            kitty @ set-background-opacity --all 0.60
            
            # If your Quickshell isn't using a FileWatcher yet, 
            # uncomment the line below to force the bar to update:
            # quickshell --reload 
        fi
        
        LAST_WALL="$CURRENT_WALL"
    fi
    
    # Wait 1 second before checking again to save battery/CPU
    sleep 1
done