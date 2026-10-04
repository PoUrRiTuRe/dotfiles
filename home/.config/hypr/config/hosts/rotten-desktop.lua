-- PC fixe : deux écrans à 165 Hz
-- ⚠️ À compléter le jour de l'installation : les noms (DP-1, DP-2, HDMI-A-1…)
-- et les résolutions exactes s'affichent avec  hyprctl monitors
-- Un écran dont le nom ne correspond pas prend la règle automatique (output = "").

-- Règle par défaut pour tout écran non listé
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1.0,
})

-- Écran principal : MSI 31,5" VA 165 Hz (à gauche)
hl.monitor({
  output = "DP-1",
  mode = "2560x1440@165",
  position = "0x0",
  scale = 1.0,
})

-- Écran secondaire : 27" IPS 165 Hz (à droite du principal)
hl.monitor({
  output = "DP-2",
  mode = "2560x1440@165",
  position = "2560x0",
  scale = 1.0,
})
