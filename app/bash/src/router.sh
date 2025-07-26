#!/usr/bin/env bash

CREDENTIALS=$ROUTER_CREDENTIALS
ADMIN_URL=$ROUTER_ADMIN_PUBLIC_URL
# ADMIN_URL=$ROUTER_ADMIN_URL

login () {
    local SESSION
    SESSION=$(http-cli \
        -d "sessionKey=$CREDENTIALS&pass=" \
        -D \
        -o /dev/null \
        "$ADMIN_URL/login-login.cgi" \
        | pcre2grep  -o  '(?<=SESSION=)[0-9]+'
    )
    if [ $? -ne 0 ];
        then echo "Error: login failed" >&2
        exit 1
    else
        echo "SESSION:$SESSION" >/dev/null
    fi
    echo "$SESSION"
}

wan () {
    http-cli \
        --header "Cookie: SESSION=$SESSION" \
        "$ADMIN_URL/wancfg.cmd?action=view" \
        | htmlq 'table tr:last-child' --text -w \
        | awk -F '\n' 'NR==1 || NR==11 || NR==12' \
        | paste -s -d ':' - | jq -R '. | split(":") | {
            iface: .[0],
            status: .[1],
            IPv4: .[2]
        }'
}

info () {
    curl --silent \
        --location "$ADMIN_URL/info.html" \
        --header "Cookie: SESSION=$SESSION" \
        | htmlq 'table' --remove-nodes 'script' --text -w \
        | pcre2grep -M '(.+):\n([^:]+)\n' \
        | tr -s '\n' | sed ':a;N;$!ba;s/:\n/:/g' \
        | awk -F ':' '{
            key=$1; value=$2;
            gsub(/^[ \t]+|[ \t]+$/, "", key);
            gsub(/^[ \t]+|[ \t]+$/, "", value);
            gsub(/ /, "_", key);  # Replace spaces with underscores in keys
            printf "\"%s\": \"%s\",", key, value;
        }' | sed '1s/^/{/; $s/,$/}/' | jq '
        . | {
            boardID:            .Board_ID,
            buildTimestamp:     .Build_Timestamp,
            version:            .Software_Version,
            lanIPv4:            .LAN_IPv4_Address,
            primaryDNS:         .Primary_DNS_Server,
            secondaryDNS:       .Secondary_DNS_Server,
            uptime:             .Uptime,
            uptimeISO: (
                (.Uptime | capture("(?<days>[0-9]+)D (?<hours>[0-9]+)H (?<minutes>[0-9]+)M (?<seconds>[0-9]+)S")) as $dur |
                (($dur.days | tonumber) * 86400 +
                 ($dur.hours | tonumber) * 3600 +
                 ($dur.minutes | tonumber) * 60 +
                 ($dur.seconds | tonumber)) as $total_seconds |
                (now | floor + $total_seconds) | strftime("%Y-%m-%dT%H:%M:%SZ")
            )
        }'
}

stations () {
    http-cli \
        --header "Cookie: SESSION=$SESSION" \
        "$ADMIN_URL/wlstationlist.cmd" \
        | htmlq 'table tr:not(:first-child)' --remove-nodes 'script' -w --text \
        | pcre2grep -o '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' |  tr '[:upper:]' '[:lower:]' \
        | jq -R | jq -s
}

reboot () {
    local reboot_key=$(http-cli \
        --header "Cookie: SESSION=$SESSION" \
        "$ADMIN_URL/resetrouter.html" \
        | htmlq 'script' -w --text \
        | pcre2grep -o1 "^var\ssessionKey\='(.+)'"
    );

    # Perform the reboot action and capture the response code
    local response_code=$(http-cli \
        --header "Cookie: SESSION=$SESSION" \
        --status-codes \
        --output /dev/null \
        "$ADMIN_URL/rebootinfo.cgi?sessionKey=$reboot_key" \
        | jq -r .http_cli_status_codes.server
    )

    # Output the result as JSON
    jq -n --arg sessionKey "$reboot_key" --arg responseCode "$response_code" \
        '{sessionKey: $sessionKey, responseCode: $responseCode|tonumber}'
}