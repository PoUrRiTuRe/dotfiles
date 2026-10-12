local mainMod = _G.mainMod or "SUPER"
local terminal = _G.terminal or "kitty"

-- Every bind has a description "Section: what it does". They feed the
-- searchable menu (SUPER + K, ~/.local/bin/keybinds-menu, via `hyprctl binds`)
-- and the cheatsheet image (scripts/make-cheatsheet.py): keep them short.
local function bind(keys, action, description, opts)
  opts = opts or {}
  opts.description = description
  hl.bind(keys, action, opts)
end

local function sh(command)
  return hl.dsp.exec_cmd(command)
end

-- ── Help ─────────────────────────────────────────────────────
bind(mainMod .. " + K", sh(os.getenv("HOME") .. "/.local/bin/keybinds-menu"), "Help: search every shortcut (this menu)")
bind(mainMod .. " + H", sh("serpantinum msg toggle guide"), "Help: Serpantinum guide and settings")

-- ── Windows ──────────────────────────────────────────────────
bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }), "Windows: focus the window on the left")
bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }), "Windows: focus the window on the right")
bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }), "Windows: focus the window above")
bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }), "Windows: focus the window below")

bind(mainMod .. " + CTRL + Left", hl.dsp.window.move({ direction = "left" }), "Windows: move the window left (or to the other monitor)")
bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ direction = "right" }), "Windows: move the window right (or to the other monitor)")
bind(mainMod .. " + CTRL + Up", hl.dsp.window.move({ direction = "up" }), "Windows: move the window up")
bind(mainMod .. " + CTRL + Down", hl.dsp.window.move({ direction = "down" }), "Windows: move the window down")

bind(mainMod .. " + SHIFT + Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), "Windows: shrink the width", { repeating = true })
bind(mainMod .. " + SHIFT + Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), "Windows: grow the width", { repeating = true })
bind(mainMod .. " + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), "Windows: shrink the height", { repeating = true })
bind(mainMod .. " + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), "Windows: grow the height", { repeating = true })

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "Windows: drag the window (SUPER + left click)", { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Windows: resize the window (SUPER + right click)", { mouse = true })

bind(mainMod .. " + W", hl.dsp.window.close(), "Windows: close the window")
bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), "Windows: toggle fullscreen")
bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }), "Windows: toggle floating")
bind(mainMod .. " + SHIFT + C", hl.dsp.window.center(), "Windows: center the floating window")
bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin({ action = "toggle" }), "Windows: pin the floating window on every workspace")
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), "Windows: switch split (side by side / stacked)")
bind("ALT + TAB", hl.dsp.window.cycle_next({ next = true }), "Windows: next window (like Windows' Alt + Tab)")

-- ── Workspaces ───────────────────────────────────────────────
-- Native Hyprland dispatchers (instant) instead of "serpantinum msg workspace"
for i = 1, 10 do
  local key = tostring(i % 10)
  bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Workspaces: go to workspace " .. i)
  bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Workspaces: send the window to workspace " .. i)
end
-- Open workspaces only, wrapping around ("+1" would create new ones endlessly)
bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }), "Workspaces: next open workspace")
bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), "Workspaces: previous open workspace")
-- Hidden "scratchpad" workspace shown on top of everything
bind(mainMod .. " + X", hl.dsp.workspace.toggle_special("scratchpad"), "Workspaces: show / hide the scratchpad")
bind(mainMod .. " + SHIFT + X", hl.dsp.window.move({ workspace = "special:scratchpad" }), "Workspaces: send the window to the scratchpad")

-- ── Apps ─────────────────────────────────────────────────────
bind(mainMod .. " + RETURN", sh(terminal), "Apps: terminal (kitty)")
bind(mainMod .. " + B", sh("brave"), "Apps: browser (Brave)")
bind(mainMod .. " + F", sh("dolphin"), "Apps: file manager (Dolphin)")
bind(mainMod .. " + D", sh("serpantinum msg toggle launcher"), "Apps: app launcher")

-- ── Serpantinum ──────────────────────────────────────────────
bind(mainMod .. " + E", sh("serpantinum msg toggle system"), "Serpantinum: system panel")
bind(mainMod .. " + SHIFT + N", sh("serpantinum msg toggle notifications"), "Serpantinum: notification center")
bind(mainMod .. " + C", sh("serpantinum msg toggle clipboard"), "Serpantinum: clipboard history")
bind(mainMod .. " + M", sh("serpantinum msg toggle music"), "Serpantinum: music player")
bind(mainMod .. " + S", sh("serpantinum msg toggle calendar"), "Serpantinum: calendar")
bind(mainMod .. " + N", sh("serpantinum msg toggle network"), "Serpantinum: network (Wi-Fi, Bluetooth)")
bind(mainMod .. " + V", sh("serpantinum msg toggle volume"), "Serpantinum: volume mixer")
bind(mainMod .. " + P", sh("serpantinum msg toggle wallpaper"), "Serpantinum: wallpaper picker")
bind(mainMod .. " + A", sh("serpantinum msg toggle autohide"), "Serpantinum: auto-hide the top bar")
bind(mainMod .. " + SHIFT + B",
  sh("serpantinum blue_light_filter status | grep -q running && serpantinum blue_light_filter reset || serpantinum blue_light_filter set 4500"),
  "Serpantinum: blue light filter on / off")
bind(mainMod .. " + R", sh("serpantinum reload"), "Serpantinum: reload the shell")

-- ── Session ──────────────────────────────────────────────────
bind(mainMod .. " + L", sh("serpantinum lock"), "Session: lock the screen", { locked = true })
bind("XF86PowerOff", sh("serpantinum lock"), "Session: lock the screen (power key)", { locked = true })
bind(mainMod .. " + SHIFT + Escape", hl.dsp.exit(), "Session: log out (back to the login screen)")
-- Lid closed: lock (sleep on battery is handled by logind)
bind("switch:on:Lid Switch", sh("serpantinum lock"), "Session: lock when the lid closes (laptop)", { locked = true })

-- ── Screenshots ──────────────────────────────────────────────
bind("Print", sh("serpantinum screenshot"), "Screenshots: area", { locked = true })
bind(mainMod .. " + SHIFT + S", sh("serpantinum screenshot"), "Screenshots: area (keyboards without Print)", { locked = true })
bind("SHIFT + Print", sh("serpantinum screenshot --edit"), "Screenshots: area, then edit", { locked = true })
bind(mainMod .. " + Print", sh("serpantinum screenshot --full"), "Screenshots: whole screen", { locked = true })
bind(mainMod .. " + SHIFT + Print", sh("serpantinum screenshot --full --edit"), "Screenshots: whole screen, then edit", { locked = true })

-- ── Media ────────────────────────────────────────────────────
-- SUPER + ALT + … duplicates the media keys for keyboards without them (Lily58)
bind(mainMod .. " + SPACE", sh("playerctl play-pause"), "Media: play / pause", { locked = true })
bind("XF86AudioPlay", sh("playerctl play-pause"), "Media: play / pause (media key)", { locked = true })
bind("XF86AudioPause", sh("playerctl play-pause"), "Media: play / pause (media key)", { locked = true })
bind(mainMod .. " + ALT + Right", sh("playerctl next"), "Media: next track", { locked = true })
bind("XF86AudioNext", sh("playerctl next"), "Media: next track (media key)", { locked = true })
bind(mainMod .. " + ALT + Left", sh("playerctl previous"), "Media: previous track", { locked = true })
bind("XF86AudioPrev", sh("playerctl previous"), "Media: previous track (media key)", { locked = true })
bind(mainMod .. " + ALT + Up", sh("serpantinum volume raise"), "Media: volume up", { repeating = true, locked = true })
bind("XF86AudioRaiseVolume", sh("serpantinum volume raise"), "Media: volume up (media key)", { repeating = true, locked = true })
bind(mainMod .. " + ALT + Down", sh("serpantinum volume lower"), "Media: volume down", { repeating = true, locked = true })
bind("XF86AudioLowerVolume", sh("serpantinum volume lower"), "Media: volume down (media key)", { repeating = true, locked = true })
bind(mainMod .. " + ALT + M", sh("serpantinum volume mute-toggle"), "Media: mute / unmute", { locked = true })
bind("XF86AudioMute", sh("serpantinum volume mute-toggle"), "Media: mute / unmute (media key)", { locked = true })
bind("XF86AudioMicMute", sh("serpantinum volume mic-toggle"), "Media: mute / unmute the microphone", { locked = true })
bind("XF86MonBrightnessUp", sh("serpantinum brightness raise"), "Media: brightness up (laptop)", { locked = true })
bind("XF86MonBrightnessDown", sh("serpantinum brightness lower"), "Media: brightness down (laptop)", { locked = true })

-- ── Touchpad ─────────────────────────────────────────────────
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
