require("config/variables")
require("config/env")
require("config/autostart")
require("config/monitors")
require("config/settings")
require("config/keybinds")

hl.config({
    general = {
        border_size = 2,
        col = {
            active_border   = { colors = {"rgba(00f0ffee)", "rgba(e600ffee)"}, angle = 45 },
            inactive_border = "rgba(59595aaa)",
        },
    },
    decoration = {
        rounding = 10,
    },
})

hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 100,
    bezier = "default",
    style = "loop",
})
