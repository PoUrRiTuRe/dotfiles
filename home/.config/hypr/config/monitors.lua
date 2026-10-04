-- Monitors: one file per machine, picked from the hostname
--   rotten-laptop  → config/hosts/rotten-laptop.lua  (ThinkPad P53)
--   rotten-desktop → config/hosts/rotten-desktop.lua (desktop PC)
-- Unknown hostname (or missing file): automatic setup, nothing breaks.

local host = ""
local ok_io, f = pcall(function() return io.open("/etc/hostname", "r") end)
if ok_io and f then
  host = (f:read("*l") or ""):gsub("%s+", "")
  f:close()
end

local loaded = host ~= "" and pcall(require, "config/hosts/" .. host)
if not loaded then
  hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1.0,
  })
end
