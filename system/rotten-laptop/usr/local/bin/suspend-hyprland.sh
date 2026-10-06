#!/bin/sh
# Met Hyprland en pause avant que la carte NVIDIA s'endorme,
# et le relance après son réveil (évite l'écran figé au réveil)
case "$1" in
    suspend) pkill -STOP -x Hyprland ;;
    resume)  pkill -CONT -x Hyprland ;;
esac
