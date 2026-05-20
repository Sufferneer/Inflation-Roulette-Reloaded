package ui;

import backend.enums.SuffTransitionStyle;
import backend.typedefs.MusicMetadata;
import flixel.addons.ui.FlxUIState;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import openfl.filters.ColorMatrixFilter;
import tjson.TJSON as Json;
import flash.media.Sound;
import openfl.filters.ShaderFilter;
import shaders.GrayscaleShader;

class SuffState extends FlxUIState {
	public static var currentMusicName:String = '';
	public static var timePassedOnState:Float = 0;
	public static var currentMusicBPM:Float = 0;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;

		if (!skip)
			openSubState(new SuffTransition(0.4, true));

		super.create();

		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	public static function playMusic(tag:String, volume:Float = 1, forceRestart:Bool = false) {
		var usedTag:String = tag;
		if (usedTag == '' || usedTag == 'null') {
			currentMusicName = 'null';
			return;
		}
		if (!forceRestart && currentMusicName == usedTag)
			return;
		//trace(Paths.getMusicPath(usedTag));
		if (!Paths.fileExists(Paths.getMusicPath(usedTag))) {
			trace('Music [$usedTag] cannot be found. Skipping');
			return;
		}
		currentMusicName = usedTag;
		FlxG.sound.playMusic(Paths.music(usedTag), volume * Preferences.data.musicVolume);
		var metadata:MusicMetadata = Paths.musicMetadata(usedTag);
		if (metadata.toast)
			MusicToast.play(metadata);
		if (metadata.loopTime == null || metadata.loopTime >= 0) {
			FlxG.sound.music.looped = true;
			if (metadata.loopTime != null)
				FlxG.sound.music.loopTime = metadata.loopTime;
		} else
			FlxG.sound.music.looped = false;
		currentMusicBPM = metadata.bpm;
	}

	public static function playSound(tag:Sound, volume:Float = 1, pitch:Float = 1) {
		var sound = new FlxSound().loadEmbedded(tag, false, true);
		sound.autoDestroy = true;
		sound.volume = volume * Preferences.data.gameSoundVolume;
		sound.pitch = pitch;
		sound.play();
	}

	public static function playUISound(tag:Sound, volume:Float = 1, pitch:Float = 1) {
		var sound = new FlxSound().loadEmbedded(tag, false, true);
		sound.autoDestroy = true;
		sound.volume = volume * Preferences.data.uiSoundVolume;
		sound.pitch = pitch;
		sound.play();
	}

	override function update(elapsed:Float) {
		timePassedOnState += elapsed;

		super.update(elapsed);
	}

	public static function switchState(nextState:FlxState = null, style:SuffTransitionStyle = DEFAULT, showLoadingText:Bool = false) {
		Main.mainClassState = Type.getClass(nextState);
		if (nextState == null)
			nextState = FlxG.state;
		if (nextState == FlxG.state) {
			resetState();
			return;
		}

		SuffTransition.style = style;
		SuffTransition.showLoadingText = showLoadingText;

		if (FlxTransitionableState.skipNextTransIn)
			FlxG.switchState(nextState);
		else
			startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState(style:SuffTransitionStyle = DEFAULT) {
		SuffTransition.style = style;
		if (FlxTransitionableState.skipNextTransIn)
			FlxG.resetState();
		else
			startTransition(FlxG.state);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public function toggleMonochrome(enable:Bool = false) {
		if (enable) {
			if (!Preferences.data.enableGLSL) return;
			var grayscale:GrayscaleShader = new GrayscaleShader();
			for (i in 0...FlxG.cameras.list.length - 1) {
				FlxG.cameras.list[i].filters = [new ShaderFilter(grayscale)];
			}
		} else {
			for (i in 0...FlxG.cameras.list.length - 1) {
				FlxG.cameras.list[i].filters = [];
			}
		}
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null) {
		if (nextState == null) {
			nextState = FlxG.state;
		}

		FlxG.state.openSubState(new SuffTransition(0.4, false));
		if (nextState == FlxG.state)
			SuffTransition.finishCallback = function() FlxG.resetState();
		else
			SuffTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function getState():SuffState {
		return cast(FlxG.state, SuffState);
	}
}
