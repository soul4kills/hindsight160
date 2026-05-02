#!/bin/sh

# =============================================================================
# wl_window.sh     Scheduled Internet Block with Whitelist
# Place at: /jffs/addons/wl_window/wl_window.sh
# =============================================================================

ADDON_DIR="/jffs/addons/wl_window"
SETTINGS="/jffs/addons/custom_settings.txt"

# --- BUILT-IN DEFAULTS -------------------------------------------------------
DEFAULT_START_HH=22
DEFAULT_START_MM=00
DEFAULT_END_HH=06
DEFAULT_END_MM=00

DEFAULT_WHITELIST_MACS="
AA:BB:CC:DD:EE:FF
11:22:33:44:55:66
"
DEFAULT_WHITELIST_INTERFACES="
wl0.1
wl0.2
"
DEFAULT_WHITELIST_IPS="
192.168.1.50
192.168.1.100
"

# --- SETTINGS HELPERS --------------------------------------------------------

cfg_get() {
    # Read a plain key from the settings file, skipping the status marker block
    [ -f "$SETTINGS" ] && grep "^$1 " "$SETTINGS" | grep -v "^#" | cut -d' ' -f2-
}

cfg_set() {
    # Write or update a plain key=value line in the settings file.
    # Never touches the WLW_STATUS marker block.
    _k="$1"; _v="$2"
    touch "$SETTINGS"
    if grep -q "^$_k " "$SETTINGS" 2>/dev/null; then
        sed -i "s|^$_k .*|$_k $_v|" "$SETTINGS"
    else
        echo "$_k $_v" >> "$SETTINGS"
    fi
}

cfg_set_status() {
    # Write the multi-line status snapshot inside its own marker block so it
    # never conflicts with plain key lines and doesn't grow the file.
    _k="$1"; _v="$2"
    touch "$SETTINGS"
    sed -i '/# WLW_STATUS_START/,/# WLW_STATUS_END/d' "$SETTINGS"
    printf '# WLW_STATUS_START\n%s %s\n# WLW_STATUS_END\n' "$_k" "$_v" >> "$SETTINGS"
}

# --- LOAD SETTINGS -----------------------------------------------------------

load_settings() {
    _shh=$(cfg_get wlw_start_hh); START_HH=${_shh:-$DEFAULT_START_HH}
    _smm=$(cfg_get wlw_start_mm); START_MM=${_smm:-$DEFAULT_START_MM}
    _ehh=$(cfg_get wlw_end_hh);   END_HH=${_ehh:-$DEFAULT_END_HH}
    _emm=$(cfg_get wlw_end_mm);   END_MM=${_emm:-$DEFAULT_END_MM}

    # Load from JSON wlw_entries written by the webui, fall back to built-in defaults
    _entries=$(cfg_get wlw_entries)

    if [ -n "$_entries" ]; then
        WHITELIST_MACS=$(echo "$_entries" | grep -o '{"type":"mac"[^}]*}' | sed 's/.*"value":"\([^"]*\)".*/\1/')
        WHITELIST_IPS=$(echo "$_entries" | grep -o '{"type":"ip"[^}]*}' | sed 's/.*"value":"\([^"]*\)".*/\1/')
        WHITELIST_INTERFACES=$(echo "$_entries" | grep -o '{"type":"int"[^}]*}' | sed 's/.*"value":"\([^"]*\)".*/\1/')
    else
        WHITELIST_MACS="$DEFAULT_WHITELIST_MACS"
        WHITELIST_IPS="$DEFAULT_WHITELIST_IPS"
        WHITELIST_INTERFACES="$DEFAULT_WHITELIST_INTERFACES"
    fi
}

# Load settings at startup
load_settings

# --- CONSTANTS ---------------------------------------------------------------
CHAIN="WL_WINDOW"
JOB_START="whitelist_window_start"
JOB_STOP="whitelist_window_stop"
SCRIPT=$(readlink -f "$0")
SERVICES_START="/jffs/scripts/services-start"

# --- FIREWALL ----------------------------------------------------------------

# Handles whether or not block survives a reboot
persist_on() {
    cfg_set "wlw_persist" "1"
    logger "wl_window" "block persistence on"
}

persist_off() {
    cfg_set "wlw_persist" "0"
    logger "wl_window" "block persistence off"
}

install_cron() {
    # Add scheduled cron jobs for start and stop times
    cru a "$JOB_START" "$START_MM $START_HH * * * $SCRIPT start"
    cru a "$JOB_STOP"  "$END_MM $END_HH * * * $SCRIPT stop"
    cfg_set "wlw_cron_active" "1"
    logger "wl_window" "(wlw_cron_active=1)"
    logger "wl_window" "Cron jobs installed: start=${START_HH}:${START_MM} stop=${END_HH}:${END_MM}"
    echo "[+] Cron jobs added for schedule: start=${START_HH}:${START_MM} stop=${END_HH}:${END_MM}"
}

uninstall_cron() {
    # Remove scheduled cron jobs
    cru d "$JOB_START" 2>/dev/null
    cru d "$JOB_STOP"  2>/dev/null
    cfg_set "wlw_cron_active" "0"
    logger "wl_window" "(wlw_cron_active=0)"
    logger "wl_window" "Cron jobs removed."
    echo "[-] Cron jobs removed."
}

apply_block() {
    # Tear down any existing rules first (silently no status write mid-flight)
    iptables  -D FORWARD -j "$CHAIN" 2>/dev/null
    iptables  -F "$CHAIN" 2>/dev/null
    iptables  -X "$CHAIN" 2>/dev/null
    ip6tables -D FORWARD -j "$CHAIN" 2>/dev/null
    ip6tables -F "$CHAIN" 2>/dev/null
    ip6tables -X "$CHAIN" 2>/dev/null

    iptables  -N "$CHAIN" 2>/dev/null
    ip6tables -N "$CHAIN" 2>/dev/null

    iptables  -A "$CHAIN" -m state --state ESTABLISHED,RELATED -j RETURN
    ip6tables -A "$CHAIN" -m state --state ESTABLISHED,RELATED -j RETURN

    for iface in $WHITELIST_INTERFACES; do
        iptables  -A "$CHAIN" -i "$iface" -j RETURN
        ip6tables -A "$CHAIN" -i "$iface" -j RETURN
    done

    for ip in $WHITELIST_IPS; do
        case "$ip" in
            *.*)  iptables  -A "$CHAIN" -s "$ip" -j RETURN ;;
            *:*)  ip6tables -A "$CHAIN" -s "$ip" -j RETURN ;;
        esac
    done

    for mac in $WHITELIST_MACS; do
        iptables  -A "$CHAIN" -m mac --mac-source "$mac" -j RETURN
        ip6tables -A "$CHAIN" -m mac --mac-source "$mac" -j RETURN
    done

    iptables  -A "$CHAIN" -j REJECT --reject-with icmp-port-unreachable
    ip6tables -A "$CHAIN" -j REJECT --reject-with icmp6-adm-prohibited
    iptables  -I FORWARD 1 -j "$CHAIN"
    ip6tables -I FORWARD 1 -j "$CHAIN"
    conntrack -F 2>/dev/null

    logger "wl_window" "Block ACTIVE whitelisted devices/interfaces bypassed."
    echo "[+] Whitelist Active: All authorized devices/interfaces bypass the block."

    # Write active flag for webui status pill, then snapshot status
    cfg_set "wlw_active" "1"
    #cfg_set_status "wlw_status" "$(show_status)"
}

remove_block() {
    iptables  -D FORWARD -j "$CHAIN" 2>/dev/null
    iptables  -F "$CHAIN" 2>/dev/null
    iptables  -X "$CHAIN" 2>/dev/null
    ip6tables -D FORWARD -j "$CHAIN" 2>/dev/null
    ip6tables -F "$CHAIN" 2>/dev/null
    ip6tables -X "$CHAIN" 2>/dev/null
    conntrack -F 2>/dev/null

    logger "wl_window" "Block INACTIVE."
    echo "[-] Whitelist Disabled."

    # Write inactive flag first so the status snapshot is accurate
    cfg_set "wlw_active" "0"
    #cfg_set_status "wlw_status" "$(show_status)"
}

show_status() {
    echo "=== Whitelist Window ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â Dual-Stack Status ==="
    echo ""
    echo "Config  : $([ -f "$SETTINGS" ] && echo "$SETTINGS" || echo "built-in defaults")"
    echo "Schedule: ON at ${START_HH}:${START_MM}, OFF at ${END_HH}:${END_MM}"
    echo ""
    if iptables -L FORWARD 2>/dev/null | grep -q "$CHAIN"; then
        echo "STATE: ACTIVE"
        echo ""
        echo "--- IPv4 Rules ($CHAIN) ---"
        iptables  -L "$CHAIN" -v -n
        echo ""
        echo "--- IPv6 Rules ($CHAIN) ---"
        ip6tables -L "$CHAIN" -v -n
    else
        echo "STATE: INACTIVE"
        echo ""
        echo "--- Whitelisted MACs ---"
        for m in $WHITELIST_MACS; do echo "  $m"; done
        echo ""
        echo "--- Whitelisted IPs ---"
        for i in $WHITELIST_IPS; do echo "  $i"; done
        echo ""
        echo "--- Whitelisted Interfaces ---"
        for n in $WHITELIST_INTERFACES; do echo "  $n"; done
    fi
}

# --- CRON / INSTALL ----------------------------------------------------------

install_script() {
    echo "[*] Installing Whitelist Window..."

    # 1. Install webui page and service-event handler
    INSTALL_SCRIPT="$ADDON_DIR/wl_window_install.sh"
    if [ -f "$INSTALL_SCRIPT" ]; then
        sh "$INSTALL_SCRIPT" install
    else
        echo "[!] wl_window_install.sh not found ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â skipping webui install."
    fi

    # 3. Ensure cron survives reboot via services-start
    #    wl_window_install.sh already adds itself to services-start for the webui,
    #    but we also need wl_window.sh install to run so cron is re-registered.
    #    Use a single canonical entry that covers both.
    if [ -f "$SERVICES_START" ]; then
        grep -q "wl_window.sh install" "$SERVICES_START" || \
            echo "sh $SCRIPT install" >> "$SERVICES_START"
    else
        printf "#!/bin/sh\nsh %s install\n" "$SCRIPT" > "$SERVICES_START"
        chmod 755 "$SERVICES_START"
    fi

    _cron_active=$(cfg_get wlw_cron_active)

    if [ "$_cron_active" = "1" ]; then
        echo "[*] wlw_cron_active=$_cron_active, installing cron schedule..."
        install_cron
    else
        echo "[*] skipping cron installation."
    fi

    # Handles block persistence on reboots - use with caution
    _persist_active=$(cfg_get wlw_persist)

    if [ "$_persist_active" = "1" ]; then
        echo "[*] wlw_persist=$_cron_active, Block persistence active..."
        apply_block
    else
        echo "[*] Block persistence inactive."
    fi

    chmod 755 /jffs/addons/wl_window/*.sh
    echo "[+] Whitelist Window fully installed."
}

uninstall_script() {
    echo "[*] Uninstalling Whitelist Window..."

    # 1. Remove iptables rules, cron jobs, and inactive flag
    remove_block

    # 2. Remove cron jobs
    cru d "$JOB_START" 2>/dev/null
    cru d "$JOB_STOP"  2>/dev/null
    echo "[-] Cron jobs removed."

    # 3. Remove services-start entry (both the install script line and the direct script line)
    if [ -f "$SERVICES_START" ]; then
        sed -i "\|sh $SCRIPT install|d" "$SERVICES_START"
        sed -i "\|wl_window_install.sh install|d" "$SERVICES_START"
    fi

    # 3. Delegate webui teardown to the install script if present
    INSTALL_SCRIPT="$ADDON_DIR/wl_window_install.sh"
    if [ -f "$INSTALL_SCRIPT" ]; then
        sh "$INSTALL_SCRIPT" uninstall
    else
        echo "[!] wl_window_install.sh not found ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â skipping webui teardown."
    fi

    # 4. Clean up all wlw_* keys from shared custom_settings.txt
    if [ -f "$SETTINGS" ]; then
        sed -i '/^wlw_/d' "$SETTINGS"
        sed -i '/# WLW_STATUS_START/,/# WLW_STATUS_END/d' "$SETTINGS"
        echo "[-] Settings removed from $SETTINGS."
    fi

    # 5. Remove the addon directory
    if [ -d "$ADDON_DIR" ]; then
        rm -rf "$ADDON_DIR"
        echo "[-] Addon directory removed: $ADDON_DIR"
    fi

    echo "[+] Whitelist Window fully uninstalled."
}

# --- MANAGE ------------------------------------------------------------------

manage_list() {
    ACTION=$1  # add | del | list
    TYPE=$2    # mac | ip | int
    VALUE=$3

    show_current() {
        echo ""
        echo "--- Current Whitelisted MACs ---"
        for item in $WHITELIST_MACS; do echo "  $item"; done
        echo ""
        echo "--- Current Whitelisted IPs ---"
        for item in $WHITELIST_IPS; do echo "  $item"; done
        echo ""
        echo "--- Current Whitelisted Interfaces ---"
        for item in $WHITELIST_INTERFACES; do echo "  $item"; done
        echo ""
        echo "(Source: $([ -f "$SETTINGS" ] && echo "$SETTINGS" || echo "built-in defaults"))"
    }

    if [ -z "$ACTION" ] || [ "$ACTION" = "list" ]; then
        echo "--- Whitelist Management ---"
        echo "Usage: $0 manage {add|del} {mac|ip|int} {value}"
        show_current
        return
    fi

    case "$TYPE" in
        mac|ip|int) ;;
        *) echo "[!] Unknown type: $TYPE (use mac, ip, or int)"; return 1 ;;
    esac

    VALUE=$(echo "$VALUE" | tr '[:upper:]' '[:lower:]')

    # Build new entries list by modifying the current wlw_entries JSON
    _entries=$(cfg_get wlw_entries)

    if [ "$ACTION" = "add" ]; then
        # Check duplicate
        echo "$_entries" | grep -q "\"value\":\"$VALUE\"" && { echo "[!] $VALUE already whitelisted."; return; }
        # Append new object before closing bracket
        new_entries=$(echo "$_entries" | sed "s/\]\$/,{\"type\":\"$TYPE\",\"value\":\"$VALUE\"}]/")
        # Handle empty array edge case
        [ "$_entries" = "[]" ] && new_entries="[{\"type\":\"$TYPE\",\"value\":\"$VALUE\"}]"
        cfg_set "wlw_entries" "$new_entries"
        echo "[+] Added $VALUE ($TYPE)"
        logger "wl_window" "Added $VALUE ($TYPE) to wlw_entries"

    elif [ "$ACTION" = "del" ]; then
        echo "$_entries" | grep -q "\"value\":\"$VALUE\"" || { echo "[!] $VALUE not found."; return; }
        # Remove the matching object (handles both mid-array and last-element commas)
        new_entries=$(echo "$_entries" | \
            sed "s/{\"type\":\"[^\"]*\",\"value\":\"$VALUE\"},\?//g" | \
            sed 's/,\]/]/' | \
            sed 's/\[,/[/')
        cfg_set "wlw_entries" "$new_entries"
        echo "[-] Removed $VALUE"
        logger "wl_window" "Removed $VALUE from wlw_entries"
    fi

    # Hot-reload firewall if currently active
    if iptables -L FORWARD 2>/dev/null | grep -q "$CHAIN"; then
        load_settings
        apply_block
    fi
}

# --- DISPATCH ----------------------------------------------------------------

case "$1" in
    start)     apply_block ;;
    stop)      remove_block ;;
    status)    show_status ;;
    install)   install_script ;;
    uninstall) uninstall_script ;;
    manage)    manage_list "$2" "$3" "$4" ;;
    cron_enable) install_cron ;;
    cron_disable) uninstall_cron ;;
    persist_enable) persist_on ;;
    persist_disable) persist_off ;;
    *)         echo "Usage: $0 {start|stop|status|install|uninstall|manage|cron_enable|cron_disable|persist_enable|persist_disable}" ;;
esac
exit 0
