hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Curseur Chroma S (croix de précision animée)
hl.env("XCURSOR_THEME", "ChromaS")
hl.env("XCURSOR_SIZE", "32")

-- Applis Qt (Dolphin...) : thème géré par qt6ct + Kvantum
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- Applis GTK (fenêtres « Enregistrer sous »...) : thème sombre forcé
hl.env("GTK_THEME", "Adwaita:dark")

-- Menu « Ouvrir avec » de Dolphin hors de Plasma
hl.env("XDG_MENU_PREFIX", "arch-")
