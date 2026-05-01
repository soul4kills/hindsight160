#!/bin/sh

OUTPUT_FILE="/jffs/scripts/network_report.txt"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
CUSTOM_DATA=$(nvram get custom_clientlist)
LAN_PREFIX=$(nvram get lan_ipaddr | cut -d. -f1-3)
TEMP_SORT="/tmp/net_audit_sort.tmp"

# 1. AUTO-DETECT Wireless Interfaces and get associated MACs
# This looks for any interface that responds to 'wl' and grabs its clients
WIFI_MACS=""
for dev in $(ip link show | awk -F': ' '/state UP/ {print $2}'); do
    if wl -i "$dev" assoclist >/dev/null 2>&1; then
        LIST=$(wl -i "$dev" assoclist | awk '{print tolower($2)}')
        WIFI_MACS="$WIFI_MACS $LIST"
    fi
done

{
    echo "Connectivity Audit - $(date)"
    echo "===================================================================================================="
    echo -e "\n=== CLIENT DEVICES (LAN/WiFi) ==="
    echo "----------------------------------------------------------------------------------------------------"
    printf "%-22s | %-22s | %-15s | %-17s | %-10s\n" "Assigned (WebUI)" "Associated (Device)" "IP Address" "MAC Address" "Status"
    echo "----------------------------------------------------------------------------------------------------"
} > "$OUTPUT_FILE"

# 2. Audit Clients
echo -n "" > "$TEMP_SORT"
cat "$LEASE_FILE" | while read -r time mac ip name id; do
    [ ${#mac} -gt 17 ] && continue
    MAC_LOWER=$(echo "$mac" | tr 'A-Z' 'a-z')
    
    STATUS="INACTIVE"
    
    # Check if MAC is in the auto-detected WiFi list
    if echo "$WIFI_MACS" | grep -q "$MAC_LOWER"; then
        STATUS="ACTIVE"
    else
        # Check wired/neighbor state (REACHABLE/DELAY/PROBE)
        NEIGH=$(ip neigh show "$ip" | grep -E "REACHABLE|DELAY|PROBE")
        [ -n "$NEIGH" ] && STATUS="ACTIVE"
    fi

    # Name Lookups
    ASSIGNED=$(echo "$CUSTOM_DATA" | tr '<' '\n' | grep -i ">$MAC_LOWER>" | awk -F'>' '{print $1}')
    [ -z "$ASSIGNED" ] && ASSIGNED="[No Manual Name]"
    [ "$name" = "*" ] && name="Unknown"

    printf "%-22s | %-22s | %-15s | %-17s | %-10s\n" "$ASSIGNED" "$name" "$ip" "$mac" "$STATUS" >> "$TEMP_SORT"
done

# Sort: ACTIVE above INACTIVE
sort -t'|' -k5 "$TEMP_SORT" >> "$OUTPUT_FILE"

# 3. Audit Gateway
{
    echo -e "\n=== ROUTER & GATEWAY DEVICES (WAN) ==="
    echo "----------------------------------------------------------------------------------------------------"
    printf "%-22s | %-22s | %-15s | %-17s | %-10s\n" "Assigned (WebUI)" "Associated (Device)" "IP Address" "MAC Address" "Status"
    echo "----------------------------------------------------------------------------------------------------"
} >> "$OUTPUT_FILE"

echo -n "" > "$TEMP_SORT"
arp -a | grep -v "($LAN_PREFIX" | while read -r line; do
    IP=$(echo "$line" | awk '{print $2}' | tr -d '()')
    MAC=$(echo "$line" | awk '{print $4}')
    [ "$MAC" = "<incomplete>" ] && continue
    
    if ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then STATUS="ACTIVE"; else STATUS="INACTIVE"; fi
    printf "%-22s | %-22s | %-15s | %-17s | %-10s\n" "[No Manual Name]" "Modem/Gateway" "$IP" "$MAC" "$STATUS" >> "$TEMP_SORT"
done

sort -t'|' -k5 "$TEMP_SORT" >> "$OUTPUT_FILE"
cat "$OUTPUT_FILE"

rm "$TEMP_SORT"
echo
echo "Audit complete. Report generated at $OUTPUT_FILE"
