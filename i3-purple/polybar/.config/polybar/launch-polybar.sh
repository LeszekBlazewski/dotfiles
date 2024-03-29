#!/bin/env bash
(
  flock 200

  killall -q polybar

  while pgrep -u $UID -x polybar > /dev/null; do sleep 0.5; done

  outputs=$(xrandr --query | grep " connected" | cut -d" " -f1)
  tray_output=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
 
  for m in $outputs; do
    export MONITOR=$m
    export TRAY_POSITION=none
    if [[ "$m" == "$tray_output" ]]; then
      TRAY_POSITION=right
    fi

    polybar --reload main </dev/null >/tmp/polybar-$m.log 2>&1 200>&- &
    disown
  done
) 200>/var/tmp/polybar-launch.lock
