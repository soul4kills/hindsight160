#!/bin/sh
# wl_window_install.sh
# Installs the Whitelist Window addon page into Asuswrt-Merlin's webui
# and registers a service-event handler.
#
# Place this at: /jffs/addons/wl_window/wl_window_install.sh
# Call from:     /jffs/scripts/services-start
#
# Usage: sh wl_window_install.sh {install|uninstall}

ADDON_DIR="/jffs/addons/wl_window"
SCRIPT="$ADDON_DIR/wl_window.sh"
ASP_SRC="$ADDON_DIR/WL_Window.asp"
SVC_EVENT="/jffs/scripts/service-event"
SVC_START="/jffs/scripts/services-start"
ADDON_TAG="wl_window"

# Merlin helper functions 
source /usr/sbin/helper.sh

install_addon() {
    # Verify firmware supports addons
    nvram get rc_support | grep -q am_addons
    if [ $? != 0 ]; then
        logger "$ADDON_TAG" "This firmware does not support addons!"
        exit 5
    fi

    # Find an available webui mount point
    am_get_webui_page "$ASP_SRC"
    if [ "$am_webui_page" = "none" ]; then
        logger "$ADDON_TAG" "No available webui mount point â€” too many addons installed."
        exit 5
    fi
    logger "$ADDON_TAG" "Mounting WL_Window.asp as $am_webui_page"

    # Mount the ASP page
    cp "$ASP_SRC" /www/user/"$am_webui_page"

    # Patch the menu tree (Tools section)
    if [ ! -f /tmp/menuTree.js ]; then
        cp /www/require/modules/menuTree.js /tmp/
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    fi
    # ParentalControl.asp
    # Tools_OtherSettings.asp

    # Insert tab after "Other Settings" in the Tools menu
    sed -i "/url: \"ParentalControl.asp\", tabName:/a {url: \"$am_webui_page\", tabName: \"WL Window\"}," \
        /tmp/menuTree.js

    # Remount (sed + bind mounts need this)
    umount /www/require/modules/menuTree.js 2>/dev/null
    mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js

    # Register service-event handler
    if [ -f "$SVC_EVENT" ]; then
        grep -q "### $ADDON_TAG" "$SVC_EVENT" || \
            printf "\n### %s start\nsh %s/wlwindow_service.sh \$*\n### %s end\n" \
                "$ADDON_TAG" "$ADDON_DIR" "$ADDON_TAG" >> "$SVC_EVENT"
    else
        printf "#!/bin/sh\n### %s start\nsh %s/wlwindow_service.sh \$*\n### %s end\n" \
            "$ADDON_TAG" "$ADDON_DIR" "$ADDON_TAG" > "$SVC_EVENT"
        chmod +x "$SVC_EVENT"
    fi

    logger "$ADDON_TAG" "Whitelist Window addon installed successfully."
    echo "[+] WL Window webui installed as $am_webui_page"
}

uninstall_addon() {
    # 1. Unmount and remove the ASP page from /www/user/
    MOUNTED=$(mount | grep "WL_Window\|wl_window" | awk '{print $3}' | head -1)
    if [ -n "$MOUNTED" ]; then
        umount "$MOUNTED" 2>/dev/null
        rm -f "$MOUNTED"
        echo "[-] Webui page unmounted: $MOUNTED"
    fi

    # 2. Remove menu entry from menuTree.js
    #    If not already bind-mounted into /tmp, copy it first so we can edit it
    if [ ! -f /tmp/menuTree.js ]; then
        cp /www/require/modules/menuTree.js /tmp/menuTree.js 2>/dev/null
    fi
    if [ -f /tmp/menuTree.js ]; then
        sed -i "/tabName: \"WL Window\"/d" /tmp/menuTree.js
        # Re-bind if it was already mounted, otherwise leave it (will take effect on next load)
        umount /www/require/modules/menuTree.js 2>/dev/null
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js 2>/dev/null
        echo "[-] Menu entry removed."
    fi

    # 3. Remove service-event block
    if [ -f "$SVC_EVENT" ]; then
        sed -i "/### $ADDON_TAG start/,/### $ADDON_TAG end/d" "$SVC_EVENT"
        echo "[-] service-event handler removed."
    fi

    # 4. Remove services-start entry
    if [ -f "$SVC_START" ]; then
        sed -i "\|sh $ADDON_DIR/wl_window_install.sh install|d" "$SVC_START"
    fi

    logger "$ADDON_TAG" "Whitelist Window webui uninstalled."
    echo "[-] Webui teardown complete."
}

case "$1" in
    install)   install_addon   ;;
    uninstall) uninstall_addon ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
