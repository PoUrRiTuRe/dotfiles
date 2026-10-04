-- Desktop PC: two 165 Hz monitors
-- TODO on install day: the output names (DP-1, DP-2, HDMI-A-1…)
-- and exact resolutions are shown by  hyprctl monitors
-- A monitor whose name doesn't match falls back to the automatic rule (output = "").

-- Default rule for any monitor not listed below
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1.0,
})

-- Main monitor: MSI 31.5" VA 165 Hz (left)
hl.monitor({
  output = "DP-1",
  mode = "2560x1440@165",
  position = "0x0",
  scale = 1.0,
})

-- Secondary monitor: 27" IPS 165 Hz (right of the main one)
hl.monitor({
  output = "DP-2",
  mode = "2560x1440@165",
  position = "2560x0",
  scale = 1.0,
})
