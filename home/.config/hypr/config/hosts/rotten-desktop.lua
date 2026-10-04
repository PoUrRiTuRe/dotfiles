-- Desktop PC: two monitors, and workspaces that span both of them
--
-- Hyprland gives each monitor its own workspace. To make "workspace N"
-- cover both screens, every number is a PAIR:
--   main monitor (MSI, DP-2)          → workspaces 1–10
--   second monitor (iiyama, HDMI-A-2) → workspaces 11–20
-- SUPER + N switches both monitors at once (N and N + 10); the focus stays
-- on the monitor you were on. SUPER + SHIFT + N moves the active window to
-- pair N, on the monitor it is on.

local MAIN   = "DP-2"      -- MSI G32CQ5P 31.5" VA, 2560x1440 @ 165 Hz
local SECOND = "HDMI-A-2"  -- iiyama PL2770H 27" IPS, 1920x1080 @ 165 Hz
local OFFSET = 10

-- Default rule for any other monitor (TV, projector…)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.0 })

-- iiyama on the left, MSI on the right (same layout as the automatic setup)
hl.monitor({ output = SECOND, mode = "1920x1080@164.92", position = "0x0",    scale = 1.0 })
hl.monitor({ output = MAIN,   mode = "2560x1440@165",    position = "1920x0", scale = 1.0 })

-- The MSI is the primary monitor for X11 / Proton games (they open on it)
hl.on("hyprland.start", function()
  hl.exec_cmd("xrandr --output " .. MAIN .. " --primary")
end)

for n = 1, 10 do
  hl.workspace_rule({ workspace = tostring(n),          monitor = MAIN,   default = (n == 1) })
  hl.workspace_rule({ workspace = tostring(n + OFFSET), monitor = SECOND, default = (n == 1) })
end

-- Pair number (1–10) of a workspace id (1–20)
local function pair_of(id)
  return ((id - 1) % OFFSET) + 1
end

local function on_second_monitor()
  local mon = hl.get_active_monitor()
  return mon ~= nil and mon.name == SECOND
end

-- Show pair n on both monitors, ending on the monitor that had the focus
local function show_pair(n)
  if on_second_monitor() then
    hl.dispatch(hl.dsp.focus({ workspace = n }))
    hl.dispatch(hl.dsp.focus({ workspace = n + OFFSET }))
  else
    hl.dispatch(hl.dsp.focus({ workspace = n + OFFSET }))
    hl.dispatch(hl.dsp.focus({ workspace = n }))
  end
end

-- Move the active window to pair n (same monitor), then show that pair
local function move_to_pair(n)
  local target = on_second_monitor() and (n + OFFSET) or n
  hl.dispatch(hl.dsp.window.move({ workspace = target, follow = false }))
  show_pair(n)
end

-- Next / previous pair that has windows on either monitor, wrapping around
local function cycle_pairs(step)
  local used = {}
  for _, ws in ipairs(hl.get_workspaces()) do
    if ws.id and ws.id >= 1 and ws.id <= 2 * OFFSET and (ws.windows or 0) > 0 then
      used[pair_of(ws.id)] = true
    end
  end
  local current = hl.get_active_workspace()
  local n = current and current.id and pair_of(current.id) or 1
  for _ = 1, OFFSET do
    n = ((n - 1 + step) % OFFSET) + 1
    if used[n] then
      show_pair(n)
      return
    end
  end
end

local mainMod = _G.mainMod or "SUPER"
for n = 1, 10 do
  local key = tostring(n % 10)
  hl.bind(mainMod .. " + " .. key, function() show_pair(n) end)
  hl.bind(mainMod .. " + SHIFT + " .. key, function() move_to_pair(n) end)
end
hl.bind(mainMod .. " + TAB", function() cycle_pairs(1) end)
hl.bind(mainMod .. " + SHIFT + TAB", function() cycle_pairs(-1) end)

-- keybinds.lua skips its own workspace keys when this is set
_G.workspace_binds_defined = true
