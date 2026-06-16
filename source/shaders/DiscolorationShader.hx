package shaders;

import flixel.system.FlxAssets.FlxShader;

class DiscolorationShader extends FlxShader {
	@:glFragmentSource('
	#pragma header
	uniform float iTime;
	uniform vec3 tintColor;
	uniform vec3 destabilizeIntensity;
	uniform float intensity;

	void main() {
		vec4 color = texture2D(bitmap, openfl_TextureCoordv);

		if (!(color.r == 1. && color.b == 1. && color.g == 1.)) {
		  color.r *= pow((tintColor.r / 255.) * (1. + destabilizeIntensity.r), intensity);
		  color.g *= pow((tintColor.g / 255.) * (1. + destabilizeIntensity.g), intensity);
		  color.b *= pow((tintColor.b / 255.) * (1. + destabilizeIntensity.b), intensity);
		}
		gl_FragColor = vec4(color.rgb, color.a);
	}
	')
	public var color(default, set):Array<Float> = [1, 1, 1];
	public var destabilization(default, set):Array<Float> = [1, 1, 1];

	private function set_color(value:Array<Float>):Array<Float> {
		color = value;
		tintColor.value = [value[0], value[1], value[2]];
		return value;
	}
	private function get_color():Array<Float> {
		return tintColor.value;
	}

	private function set_destabilization(value:Array<Float>):Array<Float> {
		destabilization = value;
		destabilizeIntensity.value = [value[0], value[1], value[2]];
		return value;
	}
	private function get_destabilization():Array<Float> {
		return destabilizeIntensity.value;
	}

	public function new(r:Float = 1, g:Float = 1, b:Float = 1) {
		super();
		time = 0.0;
		threshold = 0.75;
		color = [r, g, b];
		flashSpeed = 0.0;
	}

	public function update(elapsed:Float) {
		time += elapsed * flashSpeed;
	}
}
