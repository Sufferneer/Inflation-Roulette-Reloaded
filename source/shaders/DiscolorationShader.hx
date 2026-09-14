package shaders;

import openfl.display.BitmapData;
import flixel.system.FlxAssets.FlxShader;

class DiscolorationShader extends FlxShader {
	@:glFragmentSource('
	#pragma header
	uniform vec3 uTintColor;
	uniform float uIntensity;
	uniform bool uUseMask;
	// x = left, y = top, z = right, w = bottom
	uniform vec4 uFrameBounds;
	uniform sampler2D uMaskTexture;
	const vec3 lum = vec3(0.2126, 0.7152, 0.0722);
	
	void main() {
		vec2 uv = openfl_TextureCoordv;
		vec4 color = flixel_texture2D(bitmap, uv);
	
		// Skip math entirely if base pixel is already transparent
		if (color.a == 0.0) {
			gl_FragColor = vec4(0.0);
			return;
		}
	
		if (uUseMask) {
			vec2 localCoord = (uv - uFrameBounds.xy) / (uFrameBounds.zw - uFrameBounds.xy);
			vec4 maskColor = flixel_texture2D(uMaskTexture, uFrameBounds.xy + localCoord * (uFrameBounds.zw - uFrameBounds.xy));
			color.rgb = mix(color.rgb, uTintColor.rgb * maskColor.rgb, uIntensity * maskColor.a);
		} else {
			vec3 monocolor = vec3(dot(lum, color.rgb));
			monocolor *= uTintColor;
			color.rgb = mix(color.rgb, monocolor, uIntensity);
		}
	
		gl_FragColor = color;
	}
	')
	public var maskBitmaps:Array<BitmapData> = [];
	public var color(default, set):FlxColor = 0xFF000000;
	public var intensity(default, set):Float = 0;
	public var useMask(default, set):Bool = false;

	function set_color(value:FlxColor) {
		color = value;
		this.data.uTintColor.value = [value.redFloat, value.greenFloat, value.blueFloat];
		return value;
	}
	
	function set_intensity(value:Float) {
		this.intensity = FlxMath.bound(value, 0, 1);
		this.data.uIntensity.value = [this.intensity];
		return value;
	}

	public function new(color:FlxColor) {
		super();
		this.color = color;
		this.intensity = 0;
		this.useMask = false;
		this.data.uFrameBounds.value = [
			0,
			0,
			640,
			640
		];
	}

	public function set_useMask(value:Bool) {
		this.useMask = value;
		this.data.uUseMask.value = [value];
		return value;
	}

	public function initMask(index:Int = 0, bitmap:BitmapData):Void {
		if (index > this.maskBitmaps.length - 1) this.maskBitmaps.resize(index + 1);
		this.maskBitmaps[index] = bitmap;
	}

	public function setMask(index:Int = 0):Void {
		this.data.uMaskTexture.input = maskBitmaps[index];
	}

	public function setFrameBounds(x:Float, y:Float, width:Float, height:Float):Void {
		this.data.uFrameBounds.value = [
			x,
			y,
			width,
			height
		];
	}
}
