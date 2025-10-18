shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_enable, filter_nearest;

uniform sampler2D waterDistortionNoise : repeat_enable, filter_nearest;
uniform float distortionForce : hint_range(0.00, .1, 0.001) = .01;
uniform float WDSpeed : hint_range(1, 20, 0.05) = 4;
uniform vec2 tiling = vec2(1);
uniform vec2 offSetSpeed = vec2(.1);
uniform float backGroundDirX : hint_range(-0.1, 0.1) = 0.01;
uniform float backGroundDirY : hint_range(-0.1, 0.1) = 0.01;

void fragment() {	
	vec2 noiseUV = UV * tiling + offSetSpeed * TIME;
	float noiseValue = texture(waterDistortionNoise, noiseUV).r - 0.5;

	vec2 waterUV = UV * tiling;
	waterUV.x += offSetSpeed.x * TIME;
	waterUV.y += cos(TIME * min(1., offSetSpeed.y)) * 0.01;
	waterUV = waterUV + noiseValue * distortionForce * WDSpeed;
	
	vec2 backGroundUV = SCREEN_UV;
	backGroundUV.x += noiseValue * backGroundDirX;
	backGroundUV.y += noiseValue * backGroundDirY;
	COLOR = texture(SCREEN_TEXTURE, backGroundUV);
}
