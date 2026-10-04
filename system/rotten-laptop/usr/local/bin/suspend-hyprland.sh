#!/bin/sh
# Pause Hyprland before the NVIDIA GPU goes to sleep and resume it
# after wake-up (prevents a frozen screen on resume)
case "$1" in
    suspend) pkill -STOP -x Hyprland ;;
    resume)  pkill -CONT -x Hyprland ;;
esac
