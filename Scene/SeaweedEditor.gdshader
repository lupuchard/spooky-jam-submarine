shader_type canvas_item;

uniform float height = 4.0;

void vertex() {
	VERTEX.x += sin(VERTEX.y + TIME * 2.0) * min((1.0 - UV.y) * 4.0, 2.0);
}

void fragment() {
	if (UV.y < 1.0 / height) {
		COLOR = texture(TEXTURE, vec2(UV.x, UV.y * height));
	} else {
		COLOR = texture(TEXTURE, vec2(UV.x, 1.0));
	}
	
	COLOR *= 0.6;
}
