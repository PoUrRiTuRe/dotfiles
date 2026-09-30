#version 300 es
// ─────────────────────────────────────────────────────────────
//  nvidia-like.glsl — équivalent du panneau NVIDIA pour Hyprland
//  Réglages Windows d'origine : luminosité 60 %, contraste 65 %,
//  vibrance numérique 85 %  (valeurs NVIDIA par défaut : 50 / 50 / 50)
//
//  NVIDIA ne publie pas ses formules exactes : les valeurs ci-dessous
//  en sont une approximation. Ajuste-les à l'œil, puis recharge avec
//  « hyprshade on nvidia-like ».
// ─────────────────────────────────────────────────────────────
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// ── Réglages ─────────────────────────────────────────────────
// Luminosité : 0.0 = neutre. NVIDIA 60 % (+10) ≈ +0.05
const float BRIGHTNESS = 0.05;
// Contraste : 1.0 = neutre. NVIDIA 65 % (+15) ≈ 1.15
const float CONTRAST   = 1.15;
// Vibrance : 0.0 = neutre. NVIDIA 85 % (+35) ≈ 0.70
// (renforce surtout les couleurs ternes, comme la vibrance NVIDIA,
//  sans « brûler » celles qui sont déjà saturées)
const float VIBRANCE   = 0.70;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    vec3 c = pix.rgb;

    // 1. Vibrance
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    float sat  = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
    c = mix(vec3(luma), c, 1.0 + VIBRANCE * (1.0 - sat));

    // 2. Contraste (autour du gris moyen)
    c = (c - 0.5) * CONTRAST + 0.5;

    // 3. Luminosité
    c += BRIGHTNESS;

    fragColor = vec4(clamp(c, 0.0, 1.0), pix.a);
}
