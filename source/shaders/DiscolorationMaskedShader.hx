package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class DiscolorationMaskedShader extends FlxShader {
	@:glFragmentSource('
	#pragma header
	uniform vec3 tintColor;
	uniform vec3 destabilizeIntensity;
	uniform float intensity;
	uniform sampler2D maskTexture;

	void main() {
		vec4 color = texture2D(bitmap, openfl_TextureCoordv);
		vec4 maskColor = texture2D(maskTexture, openfl_TextureCoordv);

		color.r *= pow((tintColor.r / 255.) * (1. + destabilizeIntensity.r), intensity);
		color.g *= pow((tintColor.g / 255.) * (1. + destabilizeIntensity.g), intensity);
		color.b *= pow((tintColor.b / 255.) * (1. + destabilizeIntensity.b), intensity);

		gl_FragColor = vec4(maskColor.rgb, maskColor.a);
	}
	')
	public var color(default, set):Array<Float> = [0, 0, 0];
	public var mask(default, set):BitmapData;
	public var destabilization(default, set):Array<Float> = [0, 0, 0];
	public var strength(default, set):Float = 0;

	private function set_color(value:Array<Float>):Array<Float> {
		color = value;
		tintColor.value = [value[0], value[1], value[2]];
		return value;
	}
	private function get_color():Array<Float> {
		return tintColor.value;
	}

	private function set_mask(value:BitmapData):BitmapData {
		mask = value;
		this.data.maskTexture.input = value;
		return value;
	}
	private function get_mask():BitmapData {
		return this.mask;
	}

	private function set_destabilization(value:Array<Float>):Array<Float> {
		destabilization = value;
		return destabilizeIntensity.value = [value[0], value[1], value[2]];
	}
	private function get_destabilization():Array<Float> {
		return destabilizeIntensity.value;
	}

	private function set_strength(value:Float):Float {
		this.strength = FlxMath.bound(value, 0, 1);
		intensity.value = [this.strength];
		return value;
	}
	private function get_strength():Float {
		return intensity.value[0];
	}

	public function new(color:Array<Float>, mask:BitmapData) {
		super();
		this.color = color;
		this.destabilization = [0, 0, 0];
		this.mask = mask;
		this.strength = 0;
	}

	public function update(elapsed:Float) {
		// time += elapsed * flashSpeed;
	}
}
