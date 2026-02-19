shader_type canvas_item;

uniform vec4 overlay_color = vec4(0.2, 0.2, 0.2, 0.75);
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.999;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (tex.a >= alpha_threshold) {
        vec3 rgb = tex.rgb + overlay_color.rgb;
        COLOR = vec4(rgb, tex.a);
    } else {
        COLOR = tex;
    }
}
