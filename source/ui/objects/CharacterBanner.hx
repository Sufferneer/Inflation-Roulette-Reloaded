package ui.objects;

import backend.Gameplay;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import states.CharacterSelectState;
import shaders.DissolveShader;

class CharacterBanner extends SuffButton {
	public var designatedPlayer:String = '';
	var bg:FlxSprite;
	var character:FlxSprite;

	var allowBlinking:Bool = false;
	var blinkTick:Float = 0;

	public var dissolveShader:DissolveShader;

	public function new(playerIndex:Int) {
		var sectionWidth:Int = Std.int(Math.min(FlxG.width / Gameplay.selectedCharacterList.length, 320));
		var sectionHeight:Int = Std.int(FlxG.height * (1 - CharacterSelectState.cardOccupicationHeight));

		var color1:FlxColor = Constants.PLAYER_COLORS[playerIndex];
		var color2:FlxColor = Utilities.getDarkerShade(color1, 0.25);
		var image = FlxGraphic.fromBitmapData(FlxGradient.createGradientBitmapData(sectionWidth, sectionHeight, [color1, color2]));

		super(sectionWidth * playerIndex, y, sectionWidth, sectionHeight, false);

		if (Preferences.data.enableGLSL)
			dissolveShader = new DissolveShader();

		bg = new FlxSprite().loadGraphic(image);
		if (Preferences.data.enableGLSL)
			bg.shader = dissolveShader;

		character = new FlxSprite();
		character.visible = false;
		add(bg);
		add(character);
	}

	public static function precacheBanners() {
		for (item in Gameplay.globalCharacterList) {
			Paths.sparrowAtlas('ui/menus/characterSelect/banners/$item');
		}
		Paths.sparrowAtlas('ui/menus/characterSelect/banners/random');
	}

	public function dissolve() {
		if (Preferences.data.enableGLSL) {
			// dissolveShader.time = 0.0;
			dissolveShader.dissolve();
		} else {
			FlxTween.cancelTweensOf(bg, ['alpha']);
			FlxTween.tween(bg, {alpha: 0}, 1);
		}
	}

	public function undissolve() {
		if (Preferences.data.enableGLSL) {
			// dissolveShader.time = 1.0;
			dissolveShader.undissolve();
		} else {
			FlxTween.cancelTweensOf(bg, ['alpha']);
			FlxTween.tween(bg, {alpha: 1}, 1);
		}
	}

	public function setCharacter(char:String) {
		designatedPlayer = char;
		character.frames = Paths.sparrowAtlas('ui/menus/characterSelect/banners/$designatedPlayer');
		character.animation.addByPrefix('idle', 'idle', 24, false);
		character.animation.addByPrefix('start', 'start', 24, false);
		character.visible = true;
		allowBlinking = false;
		character.animation.play('start');
		character.x = this.x + (bg.width - character.width) / 2;
		character.y = this.y + (bg.height - character.height);
		character.clipRect = new FlxRect((bg.width - character.width) / -2, 0, bg.width, bg.height);
		character.animation.onFinish.add(function(name:String) {
			if (name == 'start') {
				allowBlinking = true;
				blinkTick = FlxG.random.float() * 3;
			}
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (dissolveShader != null)
			dissolveShader.update(elapsed);

		if (blinkTick < 0) {
			character.animation.play('idle');
			blinkTick = FlxG.random.float() * 3;
		} else if (allowBlinking) {
			blinkTick -= elapsed;
		}
	}
}
