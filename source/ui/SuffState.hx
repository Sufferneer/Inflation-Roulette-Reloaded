package ui;

import backend.enums.SuffTransitionStyle;
import backend.typedefs.MusicMetadata;
import flixel.addons.ui.FlxUIState;
import flixel.FlxState;
import openfl.media.Sound;
import openfl.filters.ShaderFilter;
import shaders.GrayscaleShader;

class SuffState extends FlxUIState {
	public static var currentMusicId:String = '';
	public static var currentMusicBPM:Float = 0;
	public var elapsedTime:Float = 0;

	public override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;

		if (!skip)
			openSubState(new SuffTransition(0.4, true));

		super.create();

		FlxTransitionableState.skipNextTransOut = false;
	}

	public static function playMusic(tag:String, volume:Float = 1, forceRestart:Bool = false) {
		var usedTag:String = tag;
		if (usedTag == '' || usedTag == 'null') {
			currentMusicId = 'null';
			return;
		}
		if (!forceRestart && currentMusicId == usedTag)
			return;
		//trace(Paths.getMusicPath(usedTag));
		if (!Paths.fileExists(Paths.getMusicPath(usedTag))) {
			trace('Music [$usedTag] cannot be found. Skipping');
			return;
		}
		currentMusicId = usedTag;
		FlxG.sound.playMusic(Paths.getMusic(usedTag), volume * Preferences.data.musicVolume);
		var metadata:MusicMetadata = Paths.getMusicMetadata(usedTag);
		/*
		if (metadata.toast)
			MusicToast.play(metadata);
		 */
		if (metadata.loopTime == null || metadata.loopTime >= 0) {
			FlxG.sound.music.looped = true;
			if (metadata.loopTime != null)
				FlxG.sound.music.loopTime = metadata.loopTime;
		} else
			FlxG.sound.music.looped = false;
		currentMusicBPM = metadata.bpm;
	}

	public static function playSound(tag:Sound, volume:Float = 1, pitch:Float = 1) {
		if (tag == null)
			tag = Paths.returnDefaultSound();
		var sound = new FlxSound().loadEmbedded(tag, false, true);
		sound.autoDestroy = true;
		sound.volume = volume * Preferences.data.gameSoundVolume;
		sound.pitch = pitch;
		sound.play();
	}

	public static function playUISound(tag:Sound, volume:Float = 1, pitch:Float = 1) {
		if (tag == null)
			tag = Paths.returnDefaultSound();
		var sound:FlxSound = new FlxSound().loadEmbedded(tag, false, true);
		sound.autoDestroy = true;
		sound.volume = volume * Preferences.data.uiSoundVolume;
		sound.pitch = pitch;
		sound.play();
	}

	public override function update(elapsed:Float) {
		elapsedTime += elapsed;
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
			for (i in 0...FlxG.cameras.list.length - 1) {
				FlxG.cameras.list[i].filters = [new ShaderFilter(new GrayscaleShader())];
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
