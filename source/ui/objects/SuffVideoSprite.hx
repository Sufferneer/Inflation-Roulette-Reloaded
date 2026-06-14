package ui.objects;

import hxvlc.flixel.FlxVideoSprite;

class SuffVideoSprite extends FlxVideoSprite {
	public var playbackRate(default, set):Float = 1.0;
	public var time(default, set):Int;
	public var length(get, never):Int;
	public var volume(default, set):Float = 1.0;
	public var isPlaying(get, never):Bool;

	function set_playbackRate(value:Float):Float {
		if (bitmap != null) bitmap.rate = value;
		return playbackRate = value;
	}
	inline function get_isPlaying():Bool return bitmap != null && bitmap.isPlaying;

	function set_time(value:Int):Int {
		if (bitmap != null) bitmap.time = value;
		return time = value;
	}
	inline function get_time():Int {
		return bitmap != null ? haxe.Int64.toInt(bitmap.time) : -1;
	}

	inline function get_length():Int {
		return bitmap != null ? haxe.Int64.toInt(bitmap.length) : -1;
	}

	function set_volume(value:Float):Float {
		value = Math.max(value, 0.0);
		if (bitmap != null) bitmap.volume = Std.int(value * 100);
		return volume = value;
	}

	public function new(x:Float, y:Float, oneTimeUse:Bool = true) {
		super(x, y);

		this.antialiasing = !Preferences.data.enableForcedAliasing;
		this.bitmap.onFormatSetup.add(function():Void {});
		if (oneTimeUse) bitmap.onEndReached.add(this.destroy, true, -10);
	}

	public function start(delay:Float = 0) {
		new FlxTimer().start(delay, (_) -> this.play());
	}

	public function onEnd(func:Void->Void, once:Bool = false, priority:Int = 0) {
		if (bitmap != null) bitmap.onEndReached.add(func, once, priority);
	}

	public function onStart(func:Void->Void, once:Bool = false, priority:Int = 0) {
		if (bitmap != null) bitmap.onOpening.add(func, once, priority);
	}

	public function onFormat(func:Void->Void, once:Bool = false, priority:Int = 0) {
		if (bitmap != null) bitmap.onFormatSetup.add(func, once, priority);
	}

	public function onStop(func:Void->Void, once:Bool = false, priority:Int = 0) {
		if (bitmap != null) bitmap.onStopped.add(func, once, priority);
	}

	public function onError(func:String->Void, once:Bool = false, priority:Int = 0) {
		if (bitmap != null) bitmap.onEncounteredError.add(func, once, priority);
	}

	public function skip() {
		if (bitmap != null && bitmap.isPlaying) {
			bitmap.stop();
		}
	}

	public function fitToScreen() {
		setGraphicSize(FlxG.width, FlxG.height);
		updateHitbox();
		screenCenter();
	}
}
