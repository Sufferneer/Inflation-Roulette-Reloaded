package shaders;

import flixel.system.FlxAssets.FlxShader;

class BloomShader extends FlxShader {
	public var intensity(default, set):Float = 1.0;
	public var blurSize(default, set):Float = 2.0;
	public var threshold(default, set):Float = 0.0;
	public var direction(default, set):Array<Float> = [1.0, 1.0];
	function set_intensity(value:Float) {
		this.intensity = value;
		this.data.uIntensity.value = [value];
		return value;
	}
	function set_blurSize(value:Float) {
		this.blurSize = value;
		this.data.uBlurSize.value = [value];
		return value;
	}
	function set_threshold(value:Float) {
		this.threshold = value;
		this.data.uThreshold.value = [value];
		return value;
	}
	function set_direction(value:Array<Float>) {
		this.direction = [value[0], value[1]];
		this.data.uDirection.value = [value[0], value[1]];
		return value;
	}
	@:glFragmentSource('
	#pragma header

	// Original: Simple Bloom 1pass - teo05
	// https://www.shadertoy.com/view/M3KyRc
	uniform float uThreshold;
	uniform float uIntensity;
	uniform float uBlurSize;
	uniform vec2 uDirection;
	
	vec4 blurColor(in vec2 coord, in sampler2D tex, in float mipBias) {
		vec2 texelSize = mipBias / openfl_TextureSize.xy;
		
		vec4 color = vec4(0.0);
		for (float x = -texelSize.x; x <= texelSize.x; x += texelSize.x / mipBias) {
			for (float y = -texelSize.y; y <= texelSize.y; y += texelSize.y / mipBias) {
				color += texture(tex, coord + vec2(x, y), mipBias) / mipBias;
			}
		}
	
		return color / 9.0 / mipBias;
	}
	
	
	void main() {
		vec2 uv = openfl_TextureCoordv;
		
		vec4 color = flixel_texture2D(bitmap, uv);
		vec4 highlight = clamp(blurColor(uv, bitmap, uBlurSize) - uThreshold, 0.0, 1.0) * 1.0 / (1.0 - uThreshold);
			
		gl_FragColor = 1.0 - (1.0 - color) * (1.0 - highlight * uIntensity); //Screen Blend Mode
	}
	')
	public function new(intensity:Float = 1.0, blurSize:Float = 2.0, threshold:Float = 0.0) {
		super();
		this.intensity = intensity;
		this.blurSize = blurSize;
		this.threshold = threshold;
		this.direction = [1, 1];
	}
}
