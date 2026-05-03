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
# $1 = "restart"   $2 = event name
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
# cfg_set: write or update a key, preserving the file inode (cp-over).
# Renaming via sed -i changes the inode which Merlin's config daemon treats
# as a trigger to restart services â€” dropping active SSH sessions.
# ---------------------------------------------------------------------------
cfg_set() {
    _k="$1"; _v="$2"
    touch "$SETTINGS"

    _tries=0
    while ! mkdir "${SETTINGS_LOCK}.dir" 2>/dev/null; do
        _tries=$((_tries + 1))
        [ "$_tries" -gt 20 ] && {
            logger -t "wl_window" "Lock timeout in cfg_set ($1)"
            return 1
        }
        sleep 0.1
    done

    _tmp="${SETTINGS}.wlw.tmp"
    # Always use grep -v + append rather than sed replacement.
    # sed "s|...|$_v|" would interpret backslashes in $_v (e.g. \u0020 -> u0020),
    # corrupting JSON unicode escapes.  grep -v strips the old line and we
    # append the new one verbatim, so backslashes are preserved exactly.
    grep -v "^$_k " "$SETTINGS" > "$_tmp" 2>/dev/null
    printf '%s %s\n' "$_k" "$_v" >> "$_tmp"
    cp "$_tmp" "$SETTINGS"
    rm -f "$_tmp"
    rmdir "${SETTINGS_LOCK}.dir" 2>/dev/null
}

# ---------------------------------------------------------------------------
# _js_str VAL
# Escapes a shell string for safe embedding inside a JSON string value.
# ---------------------------------------------------------------------------
_js_str() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# ---------------------------------------------------------------------------
# cfg_set_json KEY JSON
# Encodes spaces as \u0020 and writes the result via cfg_set.
# Spaces are encoded directly in awk to avoid shell subshell/backslash
# mangling that occurs when passing through $() or sed replacement strings.
# JavaScript's JSON.parse decodes \u0020 back to spaces automatically.
# ---------------------------------------------------------------------------
cfg_set_json() {
    _k="$1"; _json="$2"
    _encoded=$(printf '%s' "$_json" | awk '{gsub(/ /, "\\u0020"); printf "%s", $0}')
    cfg_set "$_k" "$_encoded"
}

# ---------------------------------------------------------------------------
# generate_webui_data
#
# Builds and writes three keys into custom_settings.txt:
#
#   wlw_resolve  â€” JSON object: MAC/IP -> { assigned, associated }
#                  Used by the whitelist table to show resolved names.
#
#   wlw_clients  â€” JSON array: known LAN clients with status, names, IP, MAC.
#                  Used by the add-entry client picker dropdown.
#
#   wlw_ifaces   â€” JSON array: active LAN interface names.
#                  Used by the add-entry interface picker dropdown.
#
# Spaces in JSON string values are encoded as \u0020 before writing so they
# survive the "key<space>value" line format of custom_settings.txt.
# JavaScript's JSON.parse decodes \u0020 transparently â€” no client-side
# decode step needed.
#
# Exclusions (clients + interfaces):
#   - WAN interface and its MAC / IP
#   - The router itself (lan_ipaddr, lan_hwaddr)
#   - Bridge interfaces (br0, br1, ...) â€” these are the LAN bridge, not clients
#   - Loopback and tunnel interfaces (lo, sit, ip6tnl, tunl)
#   - Incomplete ARP / lease entries
# ---------------------------------------------------------------------------
generate_webui_data() {
    LEASE_FILE="/var/lib/misc/dnsmasq.leases"
    CUSTOM_DATA=$(nvram get custom_clientlist)
    WAN_IFACE=$(nvram get wan0_ifname)
    WAN_IP=$(nvram get wan0_ipaddr)
    WAN_MAC=$(nvram get wan0_hwaddr | tr 'A-Z' 'a-z')
    LAN_IP=$(nvram get lan_ipaddr)
    LAN_MAC=$(nvram get lan_hwaddr | tr 'A-Z' 'a-z')

    # Current whitelist entries (for resolve map)
    _entries=$(grep "^wlw_entries " "$SETTINGS" 2>/dev/null | cut -d' ' -f2-)

    # Detect active WiFi MACs across all wireless interfaces
    WIFI_MACS=""
    for dev in $(ip link show | awk -F': ' '/state UP/ {print $2}'); do
        if wl -i "$dev" assoclist >/dev/null 2>&1; then
            LIST=$(wl -i "$dev" assoclist | awk '{print tolower($2)}')
            WIFI_MACS="$WIFI_MACS $LIST"
        fi
    done

    # ----------------------------------------------------------------
    # 1. wlw_resolve  { "mac-or-ip": { "assigned":"...", "associated":"..." } }
    # ----------------------------------------------------------------
    _resolve_json="{"
    _first=1

    if [ -n "$_entries" ]; then
        _macs=$(echo "$_entries" | grep -o '"type":"mac","value":"[^"]*"' | sed 's/.*"value":"\([^"]*\)".*/\1/')
        _ips=$(echo  "$_entries" | grep -o '"type":"ip","value":"[^"]*"'  | sed 's/.*"value":"\([^"]*\)".*/\1/')

        for mac in $_macs; do
            MAC_UPPER=$(echo "$mac" | tr 'a-z' 'A-Z')
            MAC_LOWER=$(echo "$mac" | tr 'A-Z' 'a-z')

            assigned=$(echo "$CUSTOM_DATA" | tr '<' '\n' | grep -i ">$MAC_LOWER>" | awk -F'>' '{print $1}')
            [ -z "$assigned" ] && \
            assigned=$(echo "$CUSTOM_DATA" | tr '<' '\n' | grep -i ">$MAC_UPPER>" | awk -F'>' '{print $1}')

            associated=""
            if [ -f "$LEASE_FILE" ]; then
                associated=$(awk -v m="$MAC_LOWER" \
                    'tolower($2)==m && $4!="*" {print $4; exit}' "$LEASE_FILE")
            fi

            [ "$_first" != "1" ] && _resolve_json="${_resolve_json},"
            _resolve_json="${_resolve_json}\"${MAC_LOWER}\":{\"assigned\":\"$(_js_str "$assigned")\",\"associated\":\"$(_js_str "$associated")\"}"
            _first=0
        done

        for ip in $_ips; do
            associated=""
            assoc_mac=""
            if [ -f "$LEASE_FILE" ]; then
                associated=$(awk -v i="$ip" '$3==i && $4!="*" {print $4; exit}' "$LEASE_FILE")
                assoc_mac=$(awk  -v i="$ip" '$3==i {print tolower($2); exit}' "$LEASE_FILE")
            fi

            assigned=""
            if [ -n "$assoc_mac" ]; then
                MAC_UPPER=$(echo "$assoc_mac" | tr 'a-z' 'A-Z')
                assigned=$(echo "$CUSTOM_DATA" | tr '<' '\n' | grep -i ">$assoc_mac>" | awk -F'>' '{print $1}')
                [ -z "$assigned" ] && \
                assigned=$(echo "$CUSTOM_DATA" | tr '<' '\n' | grep -i ">$MAC_UPPER>" | awk -F'>' '{print $1}')
            fi

            [ "$_first" != "1" ] && _resolve_json="${_resolve_json},"
            _resolve_json="${_resolve_json}\"${ip}\":{\"assigned\":\"$(_js_str "$assigned")\",\"associated\":\"$(_js_str "$associated")\"}"
            _first=0
        done
    fi

    _resolve_json="${_resolve_json}}"
    cfg_set_json "wlw_resolve" "$_resolve_json"

    # ----------------------------------------------------------------
    # 2. wlw_clients  [ { "value":"mac", "ip":"...", "assigned":"...",
    #                     "associated":"...", "status":"ACTIVE|INACTIVE" } ]
    # ----------------------------------------------------------------
    _clients_json="["
    _first=1

    if [ -f "$LEASE_FILE" ]; then
        while read -r _time _mac _ip _name _id; do
            [ ${#_mac} -gt 17 ] && continue

            MAC_LOWER=$(echo "$_mac" | tr 'A-Z' 'a-z')
            MAC_UPPER=$(echo "$_mac" | tr 'a-z' 'A-Z')

            # Exclude router and WAN
            [ "$MAC_LOWER" = "$LAN_MAC" ] && continue
            [ "$MAC_LOWER" = "$WAN_MAC" ] && continue
            [ "$_ip"       = "$LAN_IP"  ] && continue
            [ "$_ip"       = "$WAN_IP"  ] && continue

            # Active status
            STATUS="INACTIVE"
            if echo "$WIFI_MACS" | grep -q "$MAC_LOWER"; then
                STATUS="ACTIVE"
            else
                NEIGH=$(ip neigh show "$_ip" 2>/dev/null | grep -E "REACHABLE|DELAY|PROBE")
                [ -n "$NEIGH" ] && STATUS="ACTIVE"
            fi

            # Names
            assigned=$(echo "$CUSTOM_DATA" | tr '<' '\n' | grep -i ">$MAC_LOWER>" | awk -F'>' '{print $1}')
            [ -z "$assigned" ] && \
            assigned=$(echo "$CUSTOM_DATA" | tr '<' '\n' | grep -i ">$MAC_UPPER>" | awk -F'>' '{print $1}')
            [ "$_name" = "*" ] && _name=""

            [ "$_first" != "1" ] && _clients_json="${_clients_json},"
            _clients_json="${_clients_json}{\"value\":\"${MAC_LOWER}\",\"ip\":\"${_ip}\",\"assigned\":\"$(_js_str "$assigned")\",\"associated\":\"$(_js_str "$_name")\",\"status\":\"${STATUS}\"}"
            _first=0
        done < "$LEASE_FILE"
    fi

    _clients_json="${_clients_json}]"
    cfg_set_json "wlw_clients" "$_clients_json"

    # ----------------------------------------------------------------
    # 3. wlw_ifaces  [ { "value":"wl0", "label":"wl0" }, ... ]
    #
    # Excluded:
    #   - WAN interface
    #   - lo, sit, ip6tnl, tunl  (loopback / tunnels)
    #   - br*  (LAN bridge â€” router-owned, not a client interface)
    # ----------------------------------------------------------------
    _ifaces_json="["
    _first=1

    for iface in $(ip link show | awk -F': ' '/state UP/ {print $2}' | grep -v '^lo$'); do
        [ "$iface" = "$WAN_IFACE" ] && continue
        echo "$iface" | grep -qE '^(lo|sit|ip6tnl|tunl|br)' && continue

        [ "$_first" != "1" ] && _ifaces_json="${_ifaces_json},"
        _ifaces_json="${_ifaces_json}{\"value\":\"${iface}\",\"label\":\"${iface}\"}"
        _first=0
    done

    _ifaces_json="${_ifaces_json}]"
    cfg_set_json "wlw_ifaces" "$_ifaces_json"

    logger -t "wl_window" "Webui data written to $SETTINGS (resolve, clients, ifaces)"
}

case "$EVENT" in

    wlwindow_start)
        logger -t "wl_window" "Manual block start triggered from webui."
        sh "$SCRIPT" start
        generate_webui_data
        ;;

    wlwindow_stop)
        logger -t "wl_window" "Manual block stop triggered from webui."
        sh "$SCRIPT" stop
        generate_webui_data
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

    wlwindow_refresh)
        logger -t "wl_window" "Refreshing webui data on install."
        generate_webui_data
        ;;

    wlwindow)
        logger -t "wl_window" "Applying settings from webui..."

        _cron_active=$(grep "^wlw_cron_active " "$SETTINGS" 2>/dev/null | cut -d' ' -f2)
        if [ "$_cron_active" = "1" ]; then
            logger -t "wl_window" "Reinstalling cron with new schedule (times + days)."
            sh "$SCRIPT" cron_enable
        fi

        if iptables -L FORWARD 2>/dev/null | grep -q "WL_WINDOW"; then
            logger -t "wl_window" "Block is active â€” reloading rules with new settings."
            sh "$SCRIPT" start
        fi

        generate_webui_data

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
