#!/bin/bash

# Terminate already running dunst instances
killall -q dunst

# Launch dunst notification service
dunst &

