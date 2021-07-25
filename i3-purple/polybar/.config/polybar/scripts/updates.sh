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

get_total_updates

if [ "$updates" -gt 0 ]; then
    echo "$BAR_ICON $updates"
else
    echo ""
fi
