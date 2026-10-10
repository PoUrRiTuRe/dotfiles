hl.config({
  general = {
    border_size = 2,
    gaps_in = 4,
    gaps_out = 6,
    float_gaps = 6,
    resize_on_border = true,
    extend_border_grab_area = 30,
    col = {
      active_border   = { colors = {"rgba(00f0ffee)", "rgba(e600ffee)"}, angle = 45 },
      inactive_border = "rgba(59595aaa)",
    },
  },

  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    -- NVIDIA-control-panel-like colors (brightness 60 / contrast 65 / vibrance 85)
    screen_shader = "/home/rotten_guy/.config/hypr/shaders/nvidia-like.glsl",
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      new_optimizations = true,
    },
    shadow = {
      enabled = false,
    },
  },

  input = {
    kb_layout = "us",
    kb_options = "grp:alt_shift_toggle",
    accel_profile = "flat",
    -- sensitivity = -0.3,
    touchpad = {
      natural_scroll = true,
      disable_while_typing = false,
    },
  },

  misc = {
    focus_on_activate = false,
    font_family = "JetBrains Mono",
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})

-- Curves
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("linear",   { type = "bezier", points = { {0.0, 0.0}, {1.0, 1.0} } })   -- constant speed
hl.curve("smooth",   { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } }) -- smooth fade

-- Windows, layers, workspaces
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })

-- Border: smooth fade on focus change
hl.animation({ leaf = "border", enabled = true, speed = 7.5, bezier = "smooth" })
-- Border: continuous, steady gradient rotation (one turn every ~10 s)
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "linear", style = "loop" })

-- Workaround for a kitty bug (issue #10442)
hl.window_rule({ ["fullscreen_state"] = "0 0", ["match"] = { ["class"] = "kitty" } })
