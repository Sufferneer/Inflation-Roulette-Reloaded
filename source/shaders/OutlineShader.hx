package shaders;

import flixel.system.FlxAssets.FlxShader;

class OutlineShader extends FlxShader {
	public var color(default, set):FlxColor;
	public var thickness(default, set):Float = 4.0;
	public var enabled(default, set):Bool = true;
	public var lineBoilStep(default, set):Float = 6.0;
	public var lineBoilTick(default, set):Float = 0.0;
	public var lineBoil(default, set):Bool = false;
	function set_color(value:FlxColor) {
		this.color = value;
		this.data.uColor.value = [value.redFloat, value.greenFloat, value.blueFloat, value.alphaFloat];
		return value;
	}
	function set_thickness(value:Float) {
		this.thickness = value;
		this.data.uThickness.value = [value];
		return value;
	}
	function set_enabled(value:Bool) {
		this.enabled = value;
		this.data.uEnabled.value = [value];
		return value;
	}
	function set_lineBoilStep(value:Float) {
		this.lineBoilStep = value;
		this.data.uLineBoilStep.value = [value];
		return value;
	}
	function set_lineBoilTick(value:Float) {
		this.lineBoilTick = value;
		this.data.uLineBoilTick.value = [value];
		return value;
	}
	function set_lineBoil(value:Bool) {
		this.lineBoil = value;
		this.data.uLineBoil.value = [value];
		return value;
	}
	@:glFragmentSource('
	#pragma header
	uniform vec4 uColor;
	uniform float uThickness;
	uniform float uLineBoilTick;
	uniform float uLineBoilStep;
	uniform bool uLineBoil;
	uniform bool uEnabled;
	
	const float PI = 3.141592654;
	
	float hash(float p) {
		p = fract(p * 0.1031);
		p *= p + 33.33;
		p *= p + p;
		return 1.0 - fract(p);
	}
	
	float perlin1d(float x) {
		float i = floor(x);
		float f = fract(x);
		
		float u = f * f * (3.0 - 2.0 * f);
		
		float n0 = hash(i) * (f - 0.0);
		float n1 = hash(i + 1.0) * (f - 1.0);
		
		return abs(mix(n0, n1, u) * 2.0); // Scale for visual range
	}
	
	void main() {
		vec2 uv = openfl_TextureCoordv;
		vec4 texColor = texture2D(bitmap, uv);
		if (!uEnabled || texColor.a > 0.0) {
			gl_FragColor = texColor;
			return;
		}
		float alpha = 0.0;
		float thickness = uThickness;
		if (uLineBoil) {
			float tick = floor(uLineBoilTick * uLineBoilStep) / uLineBoilStep;
			thickness += perlin1d(uv.x * openfl_TextureSize.x / 80.0 + tick * 90.0) * uThickness * 2.5;
		}
		vec2 inc = thickness / openfl_TextureSize.xy;
		float iterations = thickness * 4.0;
		for (float i = 0.0; i <= iterations; i += 1.0) {
			float outlineX = sin(i / iterations * PI * 2.0) * inc.x;
			float outlineY = cos(i / iterations * PI * 2.0) * inc.y;
			alpha += texture2D(bitmap, uv + vec2(outlineX, outlineY)).a;
		}
		if (alpha > 0.0) {
			gl_FragColor = uColor;
		} else {
			gl_FragColor = vec4(0.0);
		}
	}
	')
	public function new(color:FlxColor = 0xFFFFFFFF, thickness:Float = 4) {
		super();
		this.color = color;
		this.thickness = thickness;
		this.enabled = true;
		this.lineBoilTick = 0.0;
		this.lineBoilStep = 0.0;
		this.lineBoil = false;
	}
	
	public function update(elapsed:Float = 1 / 60) {
		this.lineBoilTick += elapsed;
	}
}
