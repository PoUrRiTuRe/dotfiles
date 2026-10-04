-- Écrans : un fichier par machine, choisi selon le nom de la machine
--   rotten-laptop  → config/hosts/rotten-laptop.lua  (ThinkPad P53)
--   rotten-desktop → config/hosts/rotten-desktop.lua (PC fixe)
-- Nom inconnu (ou fichier absent) : réglage automatique, rien ne casse.

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
