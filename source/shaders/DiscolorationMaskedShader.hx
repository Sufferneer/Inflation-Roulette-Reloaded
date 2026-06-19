package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class DiscolorationMaskedShader extends FlxShader {
	@:glFragmentSource('
	#pragma header
        uniform vec3 tintColor;
        uniform vec3 destabilizeIntensity;
        uniform float intensity;
        uniform sampler2D excludeMaskTexture;

        uniform bool useMask;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            vec4 excludeMaskColor = flixel_texture2D(excludeMaskTexture, openfl_TextureCoordv);

            // Skip math entirely if base pixel is already transparent
            if (color.a == 0.0) {
                gl_FragColor = vec4(0.0);
                return;
            }

            color.r *= pow((tintColor.r / 255.) * (1. + destabilizeIntensity.r), intensity * (1.0 - excludeMaskColor.a));
			color.g *= pow((tintColor.g / 255.) * (1. + destabilizeIntensity.g), intensity * (1.0 - excludeMaskColor.a));
			color.b *= pow((tintColor.b / 255.) * (1. + destabilizeIntensity.b), intensity * (1.0 - excludeMaskColor.a));

			gl_FragColor = vec4(color.rgb, color.a);
		}
	')
	public var color(default, set):Array<Float> = [0, 0, 0];
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

	public function new(color:Array<Float>) {
		super();
		this.useMask.value = [true];
		this.color = color;
		this.destabilization = [0, 0, 0];
		this.strength = 0;
	}

	public function setMask(bitmap:BitmapData):Void {
		this.useMask.value = [(bitmap != null)];
		this.excludeMaskTexture.input = bitmap;
	}

	public function update(elapsed:Float) {
		// time += elapsed * flashSpeed;
	}
}
