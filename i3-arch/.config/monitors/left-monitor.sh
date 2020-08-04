#!/bin/bash

# executed from i3 config on i3 restart mod+shift+r
# when HDMI2 connected setup for left monitor
# when HDMI2 disconnected setup only for main display (mod+shift+r)

if xrandr | grep 'HDMI-2 connected' ; then
    xrandr --output eDP1 --auto --output HDMI-2 --auto --left-of eDP-1
else
     xrandr --output eDP-1 --auto --output HDMI-2 --off
fi