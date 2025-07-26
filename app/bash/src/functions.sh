#!/bin/bash

# strict mode
set -euo pipefail

. "$LAMBDA_TASK_ROOT/router.sh"
. "$LAMBDA_TASK_ROOT/helpers.sh"

function handle_login () {
    local EVENT="$1"
    lambda_parse_event "$EVENT"
    lambda_require_http_event
    local SESSION
    SESSION=$(login)
    if [[ -z "$SESSION" ]]; then
        lambda_error_response "Unauthorized" 401
    else
        local data=$(jq -n --arg session "$SESSION" \
            '{ session: $session }'
        )
        lambda_ok_response  "$data"
    fi
}

function handle_wan () {
    ensure_session
    local data
    data=$(wan)
    if [[ -z "$data" ]]; then
        jq -n '{
            statusCode: 500,
            body: "Error",
            headers: {
                "Content-Type": "application/json"
            }
        }'
        exit 1
    else
        jq -n --argjson data "$data" '{
            statusCode: 200,
            body: ($data|tostring),
            headers: {
                "Content-Type": "application/json"
            }
        }'
    fi
}

function handle_info () { 
    ensure_session
    local data=$(info)
    if [[ -z "$data" ]]; then
        lambda_error_response "Error" 500
        exit 1
    else
        lambda_ok_response "$data"
    fi
}

function handle_stations () {
    ensure_session
    local data=$(stations)
    if [[ -z "$data" ]]; then
        lambda_error_response "Error" 500
        exit 1
    else
        lambda_ok_response "$data"
    fi
}

function handle_reboot () {
    ensure_session
    local data=$(reboot)
    if [[ -z "$data" ]]; then
        lambda_error_response "Error" 500
        exit 1
    else
        lambda_ok_response "$data"
    fi
}

function ensure_session () {
    SESSION=$(login)
    if [[ -z "$SESSION" ]]; then
        lambda_error_response "Unauthorized" 401
        exit 1
    fi
}