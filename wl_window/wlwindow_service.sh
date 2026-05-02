#!/bin/sh
# wlwindow_service.sh
# Called by /jffs/scripts/service-event via Merlin's service-event dispatch.
#
# Merlin invokes this as:
#   service-event restart wlwindow
#   service-event restart wlwindow_start
#   service-event restart wlwindow_stop
#   ... etc.
#
# $1 = "restart"   $2 = event name (the full string after "restart_" in action_script)
#
# Place at: /jffs/addons/wl_window/wlwindow_service.sh

TYPE="$1"
EVENT="$2"
ADDON_DIR="/jffs/addons/wl_window"
SCRIPT="$ADDON_DIR/wl_window.sh"
SETTINGS="/jffs/addons/custom_settings.txt"
SETTINGS_LOCK="/tmp/wl_window_settings.lock"

[ "$TYPE" != "restart" ] && exit 0

# ---------------------------------------------------------------------------
# cfg_set: write or update a key in the shared settings file.
# FIX: use cp-over instead of sed -i to preserve the inode.
# Merlin's config daemon watches custom_settings.txt; a rename (sed -i)
# changes the inode, which the daemon detects and uses as a trigger to
# restart services — dropping active SSH sessions with exit code 128.
# ---------------------------------------------------------------------------
cfg_set() {
    _k="$1"; _v="$2"
    touch "$SETTINGS"

    _tries=0
    while ! mkdir "${SETTINGS_LOCK}.dir" 2>/dev/null; do
        _tries=$((_tries + 1))
        [ "$_tries" -gt 20 ] && {
            logger -t "wl_window" "Lock timeout in service script cfg_set"
            return 1
        }
        sleep 0.1
    done

    _tmp="${SETTINGS}.wlw.tmp"
    if grep -q "^$_k " "$SETTINGS" 2>/dev/null; then
        sed "s|^$_k .*|$_k $_v|" "$SETTINGS" > "$_tmp" && cp "$_tmp" "$SETTINGS"
    else
        cp "$SETTINGS" "$_tmp"
        echo "$_k $_v" >> "$_tmp"
        cp "$_tmp" "$SETTINGS"
    fi
    rm -f "$_tmp"
    rmdir "${SETTINGS_LOCK}.dir" 2>/dev/null
}

case "$EVENT" in

    wlwindow_start)
        logger -t "wl_window" "Manual block start triggered from webui."
        sh "$SCRIPT" start
        ;;

    wlwindow_stop)
        logger -t "wl_window" "Manual block stop triggered from webui."
        sh "$SCRIPT" stop
        ;;

    wlwindow_cron_enable)
        logger -t "wl_window" "Cron schedule enable triggered from webui."
        sh "$SCRIPT" cron_enable
        ;;

    wlwindow_cron_disable)
        logger -t "wl_window" "Cron schedule disable triggered from webui."
        sh "$SCRIPT" cron_disable
        ;;

    wlwindow_persist_enable)
        logger -t "wl_window" "Reboot persistence enable triggered from webui."
        sh "$SCRIPT" persist_enable
        ;;

    wlwindow_persist_disable)
        logger -t "wl_window" "Reboot persistence disable triggered from webui."
        sh "$SCRIPT" persist_disable
        ;;

    wlwindow)
        # Fired by the Apply button in the webui.
        # Merlin has already written all amng_custom fields into SETTINGS as
        # plain "key value" lines before service-event is called.
        logger -t "wl_window" "Applying settings from webui..."

        # Reinstall cron with updated schedule times if cron is enabled
        _cron_active=$(grep "^wlw_cron_active " "$SETTINGS" 2>/dev/null | cut -d' ' -f2)
        if [ "$_cron_active" = "1" ]; then
            logger -t "wl_window" "Reinstalling cron with new schedule times."
            sh "$SCRIPT" cron_enable
        fi

        # Hot-reload firewall rules if the block is currently active
        if iptables -L FORWARD 2>/dev/null | grep -q "WL_WINDOW"; then
            logger -t "wl_window" "Block is active — reloading rules with new settings."
            sh "$SCRIPT" start
        fi

        # Clean up legacy flat keys from versions prior to JSON wlw_entries
        _tries=0
        while ! mkdir "${SETTINGS_LOCK}.dir" 2>/dev/null; do
            _tries=$((_tries + 1))
            [ "$_tries" -gt 20 ] && break
            sleep 0.1
        done
        _tmp="${SETTINGS}.wlw.tmp"
        cp "$SETTINGS" "$_tmp" 2>/dev/null
        sed '/^wlw_macs /d;/^wlw_ips /d;/^wlw_ints /d' "$_tmp" > "${_tmp}.2" && cp "${_tmp}.2" "$SETTINGS"
        rm -f "$_tmp" "${_tmp}.2"
        rmdir "${SETTINGS_LOCK}.dir" 2>/dev/null

        logger -t "wl_window" "Done."
        ;;

    *)
        exit 0
        ;;

esac

exit 0
