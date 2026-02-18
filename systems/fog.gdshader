shader_type canvas_item;

uniform float highlight_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = tex + vec4(highlight_strength);
}