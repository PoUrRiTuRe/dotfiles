-- Desktop PC: two monitors, each with its own workspaces (Hyprland default)
--
-- Monitors are matched by MODEL ("desc:", start of the description shown by
-- `hyprctl monitors`), not by port name: port names (DP-2, HDMI-A-1…) change
-- with the graphics card or the cable.

local MAIN   = "desc:Microstep MSI G32CQ5P"         -- 31.5" VA, 2560x1440 @ 165 Hz
local SECOND = "desc:iiyama Corporation PL2770H"    -- 27" IPS, 1920x1080 @ 180 Hz

-- Default rule for any other monitor (TV, projector…)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.0 })

-- iiyama on the left, MSI on the right, no gap between them (a gap stops
-- the cursor from crossing). Don't set monitors in GUI tools such as hyprmod:
-- their file (hyprland-gui.lua) is loaded last and overrides these rules.
hl.monitor({ output = SECOND, mode = "1920x1080@180.01", position = "0x0",    scale = 1.0 })
hl.monitor({ output = MAIN,   mode = "2560x1440@165",    position = "1920x0", scale = 1.0 })

-- Current port name (DP-3, HDMI-A-1…) of a "desc:" selector, or nil
local function port_of(selector)
  local wanted = selector:gsub("^desc:", "")
  local ok, monitors = pcall(hl.get_monitors)
  if not ok or not monitors then
    return nil
  end
  for _, mon in ipairs(monitors) do
    if mon.description and mon.description:sub(1, #wanted) == wanted then
      return mon.name
    end
  end
  return nil
end

-- The MSI is the primary monitor for X11 / Proton games (they open on it)
hl.on("hyprland.start", function()
  local port = port_of(MAIN)
  if port then
    hl.exec_cmd("xrandr --output " .. port .. " --primary")
  end
end)
