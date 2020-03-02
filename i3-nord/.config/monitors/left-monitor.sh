#!/bin/bash

# executed from i3 config on i3 restart mod+shift+r
# when HDMI2 connected setup for left monitor
# when HDMI2 disconnected setup only for main display (mod+shift+r)

if xrandr | grep 'HDMI2 connected' ; then
    xrandr --output eDP1 --auto --output HDMI2 --auto --left-of eDP1
else
     xrandr --output eDP1 --auto --output HDMI2 --off
fi