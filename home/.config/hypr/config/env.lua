hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Cursor: Chroma S (black, animated RGB outline, precision crosshair)
hl.env("XCURSOR_THEME", "ChromaS")
hl.env("XCURSOR_SIZE", "32")

-- Qt apps (Dolphin...): theme handled by qt6ct + Kvantum
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- GTK apps ("Save as" dialogs...): force the dark theme
hl.env("GTK_THEME", "Adwaita:dark")

-- Dolphin "Open with" menu outside Plasma
hl.env("XDG_MENU_PREFIX", "arch-")
