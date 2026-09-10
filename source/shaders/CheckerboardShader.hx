package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class CheckerboardShader extends FlxShader {
	public var time(default, set):Float = 0.0;
	public var gridTexture(default, set):BitmapData;
	public var parentSize(default, set):Array<Float> = [16, 16];
	public var useAlpha(default, set):Bool = true;
	function set_time(value:Float) {
		time = value;
		this.data.iTime.value = [value];
		return value;
	}
	function set_gridTexture(value:BitmapData) {
		gridTexture = value;
		this.data.uGridTex.input = value;
		this.data.uGridSize.value = [value.width, value.height];
		return value;
	}
	function set_parentSize(value:Array<Float>) {
		parentSize = [value[0], value[1]];
		this.data.uTexSize.value = [value[0], value[1]];
		return value;
	}
	function set_useAlpha(value:Bool) {
		useAlpha = value;
		this.data.uUseAlpha.value = [value];
		return value;
	}
	@:glFragmentSource('
	#pragma header
	uniform float iTime;
	uniform sampler2D uGridTex;
	uniform vec2 uGridSize;
	uniform vec2 uTexSize;
	uniform bool uUseAlpha;
	
	void main() {
		vec2 uv = openfl_TextureCoordv;
		vec4 texColor = flixel_texture2D(bitmap, uv);
		vec2 dt = iTime / uGridSize * 32.0;
		uv -= dt;
		vec4 maskColor = flixel_texture2D(uGridTex, fract(uv * uTexSize / uGridSize));
		if (uUseAlpha) {
			if (texColor.a > 0.0) {
				gl_FragColor = vec4(maskColor.rgb, texColor.a * maskColor.a);
			} else {
				gl_FragColor = vec4(0.0);
			}
		} else {
			gl_FragColor = maskColor;
		}
	}
	')
	public function new() {
		super();
	}
	public function update(elapsed:Float = 0) {
		time += elapsed;
	}
}
