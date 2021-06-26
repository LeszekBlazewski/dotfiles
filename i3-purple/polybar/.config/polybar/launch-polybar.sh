#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# multiple monitors bars

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar main -r &
  done
else
  polybar main -r &
fi


# Example how to redirect output to tmp
# polybar left-top >> /tmp/polybar-left-top.log 2>&1 &
