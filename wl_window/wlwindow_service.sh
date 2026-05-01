#!/bin/sh
# wlwindow_service.sh
# Called by /jffs/scripts/service-event
#
# Merlin calls this as:  service-event restart wlwindow
#                        service-event restart wlwindow_start
#                        service-event restart wlwindow_stop
#
# $1 = "restart"  $2 = event name (everything after "restart_" in action_script)
#
# Place at: /jffs/addons/wl_window/wlwindow_service.sh

TYPE="$1"
EVENT="$2"

ADDON_DIR="/jffs/addons/wl_window"
SCRIPT="$ADDON_DIR/wl_window.sh"
SETTINGS="/jffs/addons/custom_settings.txt"

[ "$TYPE" != "restart" ] && exit 0

cfg_set() {
    _k="$1"; _v="$2"
    touch "$SETTINGS"
    if grep -q "^$_k " "$SETTINGS" 2>/dev/null; then
        sed -i "s|^$_k .*|$_k $_v|" "$SETTINGS"
    else
        echo "$_k $_v" >> "$SETTINGS"
    fi
}

# â”€â”€ Manual start â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if [ "$EVENT" = "wlwindow_start" ]; then
    logger "wl_window" "Manual start triggered from webui."
    sh "$SCRIPT" start
    exit 0
fi

# â”€â”€ Manual stop â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if [ "$EVENT" = "wlwindow_stop" ]; then
    logger "wl_window" "Manual stop triggered from webui."
    sh "$SCRIPT" stop
    exit 0
fi

[ "$EVENT" != "wlwindow" ] && exit 0

# â”€â”€ Apply / save settings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Merlin has already written all amng_custom fields into SETTINGS as
# plain "key value" lines before service-event is called. wlw_entries
# is already there; wl_window.sh reads and parses it directly.
# Nothing to flatten or duplicate â€” just reinstall cron and optionally
# hot-reload the firewall.

logger "wl_window" "Applying settings from webui..."

sh "$SCRIPT" install

if iptables -L FORWARD 2>/dev/null | grep -q "WL_WINDOW"; then
    logger "wl_window" "Block was active â€” reloading rules with new settings."
    sh "$SCRIPT" start
fi

# Clean up legacy flat keys if they exist from a previous version
sed -i '/^wlw_macs /d;/^wlw_ips /d;/^wlw_ints /d' "$SETTINGS" 2>/dev/null

logger "wl_window" "Done."
