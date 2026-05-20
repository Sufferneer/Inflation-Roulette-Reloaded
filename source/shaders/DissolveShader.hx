package shaders;

import flixel.system.FlxAssets.FlxShader;

class DissolveShader extends FlxShader {
	// Perlin Noise: Simple 2d perlin noise by SpectreSpect
	// https://www.shadertoy.com/view/DsK3W1

	@:glFragmentSource('
	#pragma header
	uniform float iTime;
	uniform float seed;
	vec2 n22 (vec2 p) {
		vec3 a = fract(p.xyx * vec3(123.34 + seed, 234.34, 345.65));
		a += dot(a, a + 34.45);
		return fract(vec2(a.x * a.y, a.y * a.z));
	}

	vec2 get_gradient(vec2 pos) {
		float twoPi = 6.283185;
		float angle = n22(pos).x * twoPi;
		return vec2(cos(angle), sin(angle));
	}

	float perlin_noise(vec2 uv, float cells_count) {
		vec2 pos_in_grid = uv * cells_count;
		vec2 cell_pos_in_grid = floor(pos_in_grid);
		vec2 local_pos_in_cell = (pos_in_grid - cell_pos_in_grid);
		vec2 blend = local_pos_in_cell * local_pos_in_cell * (3.0 - 2.0 * local_pos_in_cell);

		vec2 left_top = cell_pos_in_grid + vec2(0, 1);
		vec2 right_top = cell_pos_in_grid + vec2(1, 1);
		vec2 left_bottom = cell_pos_in_grid + vec2(0, 0);
		vec2 right_bottom = cell_pos_in_grid + vec2(1, 0);

		float left_top_dot = dot(pos_in_grid - left_top, get_gradient(left_top));
		float right_top_dot = dot(pos_in_grid - right_top,  get_gradient(right_top));
		float left_bottom_dot = dot(pos_in_grid - left_bottom, get_gradient(left_bottom));
		float right_bottom_dot = dot(pos_in_grid - right_bottom, get_gradient(right_bottom));

		float noise_value = mix(
								mix(left_bottom_dot, right_bottom_dot, blend.x),
								mix(left_top_dot, right_top_dot, blend.x),
								blend.y);


		return (0.5 + 0.5 * (noise_value / 0.75));
	}

	void main() {
		vec2 uv = openfl_TextureCoordv;

		float height = perlin_noise(uv * openfl_TextureSize / vec2(320.0, 320.0), 16.0);

		vec3 pixel = texture2D(bitmap, uv).rgb;

		//remove if for performance
		float condition = 1. - step(height, iTime);

		gl_FragColor = vec4(pixel * condition, condition);
	}
	')

	public var updating:Bool = false;
	public var decayRate:Float = 0.0;
	public var time(default, set):Float = 0.0;

	private function get_time():Float {
		return iTime.value[0];
	}

	private function set_time(value:Float):Float {
		time = value;
		iTime.value = [value];
		return value;
	}

	public function new() {
		super();
		time = 0.0;
		seed.value = [FlxG.random.float(-123.34, 123.34)];
	}

	public function dissolve() {
		decayRate = 1.0;
	}

	public function undissolve() {
		decayRate = -1.0;
	}

	public function update(elapsed:Float) {
		time = FlxMath.bound(time + elapsed * decayRate, 0.0, 1.0);
	}
}
