#version 300 es
// ─────────────────────────────────────────────────────────────
//  nvidia-like.glsl — NVIDIA control panel equivalent for Hyprland
//  Original Windows settings: brightness 60 %, contrast 65 %,
//  digital vibrance 85 %  (NVIDIA defaults: 50 / 50 / 50)
//
//  NVIDIA doesn't publish its exact formulas: the values below are an
//  approximation. Tune them by eye, then reload with
//  "hyprshade on nvidia-like".
// ─────────────────────────────────────────────────────────────
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// ── Settings ──────────────────────────────────────────────────
// Brightness: 0.0 = neutral. NVIDIA 60 % (+10) ≈ +0.05
const float BRIGHTNESS = 0.05;
// Contrast: 1.0 = neutral. NVIDIA 65 % (+15) ≈ 1.15
const float CONTRAST   = 1.15;
// Vibrance: 0.0 = neutral. NVIDIA 85 % (+35) ≈ 0.70
// (mostly boosts dull colors, like NVIDIA vibrance,
//  without "burning" already saturated ones)
const float VIBRANCE   = 0.70;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    vec3 c = pix.rgb;

    // 1. Vibrance
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    float sat  = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
    c = mix(vec3(luma), c, 1.0 + VIBRANCE * (1.0 - sat));

    // 2. Contrast (around mid grey)
    c = (c - 0.5) * CONTRAST + 0.5;

    // 3. Brightness
    c += BRIGHTNESS;

    fragColor = vec4(clamp(c, 0.0, 1.0), pix.a);
}
