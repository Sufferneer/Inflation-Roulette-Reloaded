package shaders;

import flixel.system.FlxAssets.FlxShader;

class DissolveShader extends FlxShader {
	@:glFragmentSource('
	#pragma header
	// Perlin Noise: Simple 2d perlin noise by SpectreSpect
	// https://www.shadertoy.com/view/DsK3W1
	
	uniform float seed;
	uniform float iTime;
	
	vec2 n22 (vec2 p) {
		vec3 a = fract(p.xyx * vec3(123.34 + seed, 234.34, 345.65));
		a += dot(a, a + 34.45);
		return fract(vec2(a.x * a.y, a.y * a.z));
	}
	
	vec2 getGradient(vec2 pos) {
		float twoPi = 6.283185;
		float angle = n22(pos).x * twoPi;
		return vec2(cos(angle), sin(angle));
	}
	
	float perlinNoise(vec2 uv, float cells_count) {
		vec2 posInGrid = uv * cells_count;
		vec2 cellPosInGrid = floor(posInGrid);
		vec2 localPosInCell = (posInGrid - cellPosInGrid);
		vec2 blend = localPosInCell * localPosInCell * (3.0 - 2.0 * localPosInCell);
	
		vec2 topLeft = cellPosInGrid + vec2(0.0, 1.0);
		vec2 topRight = cellPosInGrid + vec2(1.0, 1.0);
		vec2 bottomLeft = cellPosInGrid + vec2(0.0, 0.0);
		vec2 bottomRight = cellPosInGrid + vec2(1.0, 0.0);
	
		float topLeftDot = dot(posInGrid - topLeft, getGradient(topLeft));
		float topRightDot = dot(posInGrid - topRight, getGradient(topRight));
		float bottomLeftDot = dot(posInGrid - bottomLeft, getGradient(bottomLeft));
		float bottomRightDot = dot(posInGrid - bottomRight, getGradient(bottomRight));
	
		float noiseVal = mix(
			mix(bottomLeftDot, bottomRightDot, blend.x),
			mix(topLeftDot, topRightDot, blend.x),
			blend.y);
	
	
		return (0.5 + 0.5 * (noiseVal / 0.75));
	}
	
	void main() {
		vec2 uv = openfl_TextureCoordv;
	
		float height = perlinNoise(uv * openfl_TextureSize.xy / vec2(320.0, 320.0), 16.0);
	
		vec3 pixel = flixel_texture2D(bitmap, uv).rgb;
		
		float condition = 1.0 - step(height, iTime);
	
		gl_FragColor = vec4(pixel * condition, condition);
	}
	')
	public var updating:Bool = false;
	public var decayRate:Float = 0.0;
	public var time(default, set):Float = 0.0;

	private function get_time():Float {
		return data.iTime.value[0];
	}

	private function set_time(value:Float):Float {
		time = value;
		data.iTime.value = [value];
		return value;
	}

	public function new() {
		super();
		time = 0.0;
		data.seed.value = [FlxG.random.float(-123.34, 123.34)];
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
