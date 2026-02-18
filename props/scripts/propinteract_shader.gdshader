shader_type canvas_item;

uniform vec4 overlay_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.999;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (tex.a >= alpha_threshold) {
        COLOR = overlay_color;
    } else {
        COLOR = tex;
    }
}
