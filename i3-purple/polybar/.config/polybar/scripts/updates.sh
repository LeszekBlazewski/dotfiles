#!/bin/env bash

BAR_ICON=""

get_total_updates() {
    if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
        updates_arch=0
    fi

    if ! updates_aur=$(yay -Qua 2> /dev/null | wc -l); then
        updates_aur=0
    fi

    updates=$((updates_arch + updates_aur))
}


while true; do
    get_total_updates

    # when there are updates available
    # every 10 seconds check whether updates are done
    while [ "$updates" -gt 0 ]; do
        if [ "$updates" -ge 1 ]; then
            echo "$BAR_ICON $updates"
        else
            echo ""
        fi
        sleep 10
        get_total_updates
    done

    # when no updates are available, use a longer loop, this saves on CPU
    # and network uptime, only checking once every 1h for new updates
    while (( updates == 0 )); do
        echo ""
        sleep 3600
        get_total_updates
    done
done
