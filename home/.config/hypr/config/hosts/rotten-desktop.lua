-- Desktop PC: two monitors, and workspaces that span both of them
--
-- Hyprland gives each monitor its own workspace. To make "workspace N"
-- cover both screens, every number is a PAIR:
--   main monitor (MSI)        → workspaces 1–10
--   second monitor (iiyama)   → workspaces 11–20
-- SUPER + N switches both monitors at once (N and N + 10); the focus stays
-- on the monitor you were on. SUPER + SHIFT + N moves the active window to
-- pair N, on the monitor it is on.
--
-- Monitors are matched by MODEL ("desc:", start of the description shown by
-- `hyprctl monitors`), not by port name: port names (DP-2, HDMI-A-1…) change
-- with the graphics card or the cable.
--
-- Set SPAN_WORKSPACES to false to get Hyprland's normal behavior back
-- (one independent workspace per monitor), then run: hyprctl reload

local SPAN_WORKSPACES = true

local MAIN   = "desc:Microstep MSI G32CQ5P"         -- 31.5" VA, 2560x1440 @ 165 Hz
local SECOND = "desc:iiyama Corporation PL2770H"    -- 27" IPS, 1920x1080 @ 180 Hz
local OFFSET = 10

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

if not SPAN_WORKSPACES then
  return
end

for n = 1, 10 do
  hl.workspace_rule({ workspace = tostring(n),          monitor = MAIN,   default = (n == 1) })
  hl.workspace_rule({ workspace = tostring(n + OFFSET), monitor = SECOND, default = (n == 1) })
end

local function pair_of(id)
  return ((id - 1) % OFFSET) + 1
end

-- Port name of the monitor a workspace id belongs to
local function monitor_of(id)
  return port_of((id > OFFSET) and SECOND or MAIN)
end

local function on_second_monitor()
  local mon = hl.get_active_monitor()
  return mon ~= nil and mon.name == port_of(SECOND)
end

-- Workspace rules only apply when a workspace is created: move an existing
-- workspace back to its monitor if it ended up on the other one
local function ensure_placed(id)
  local target = monitor_of(id)
  local ok, ws = pcall(hl.get_workspace, id)
  if target and ok and ws and ws.monitor and ws.monitor.name ~= target then
    hl.dispatch(hl.dsp.workspace.move({ workspace = id, monitor = target }))
  end
end

local function focus(id)
  ensure_placed(id)
  hl.dispatch(hl.dsp.focus({ workspace = id }))
end

-- Show pair n on both monitors, ending on the monitor that had the focus
local function show_pair(n)
  if on_second_monitor() then
    focus(n)
    focus(n + OFFSET)
  else
    focus(n + OFFSET)
    focus(n)
  end
end

-- Move the active window to pair n (same monitor), then show that pair
local function move_to_pair(n)
  local target = on_second_monitor() and (n + OFFSET) or n
  ensure_placed(target)
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
  local n = (current and current.id and current.id >= 1) and pair_of(current.id) or 1
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
