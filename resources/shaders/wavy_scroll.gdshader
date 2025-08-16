//remember to set expandmode = ignore size and stretchmode = tile on texturerect
shader_type canvas_item;

uniform float amplitude = 5.0;
uniform float frequency = 10.0;
uniform float speed = 2.0;

uniform float scale = 1.0;
uniform vec2 offset = vec2(0.0, 0.0);
uniform vec2 scroll_speed = vec2(0.0, 0.0);

void fragment() {
	vec2 uv = UV;
    uv.y += sin(uv.x * frequency + TIME * speed) * (amplitude);
	COLOR = texture(
		TEXTURE, vec2(
			(uv.x - offset.x) / scale - (scroll_speed.x * TIME), 
			(uv.y - offset.y) / scale - (scroll_speed.y * TIME))
	);
}
