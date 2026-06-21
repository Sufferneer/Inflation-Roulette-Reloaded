package substates;

import backend.enums.SuffTransitionStyle;
import states.MainMenuState;
import states.PlayState;
import backend.Gameplay;

class PauseSubState extends SuffSubState {
	var menuItems:Array<String> = ['resume', 'restart', 'options', 'exit'];
	var menuItemLabelKeys:Array<String> = ['pauseMenu.resume', 'pauseMenu.restart', 'pauseMenu.options', 'menu.exit'];
	var menuButtonGroup:FlxTypedGroup<SuffButton>;
	var pauseMusic:FlxSound;

	public static var usedFollowLerp:Float = 0;

	public static var resetMusic:Bool = false;

	public function new() {
		super();

		Window.setTitle(Language.getPhrase('pauseMenu.windowDisplay'));

		FlxG.sound.music.volume = 0;
		usedFollowLerp = FlxG.camera.followLerp;
		FlxG.camera.followLerp = 0;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.75;
		add(bg);

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music('pause'));
		pauseMusic.volume = 0;
		pauseMusic.looped = true;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.fadeIn(5, 0, 0.5 * Preferences.data.musicVolume);
		MusicToast.play(Paths.musicMetadata('pause'));

		var headingText:FlxText = new FlxText(0, 0, 0, Language.getPhrase('pauseMenu.title'), 48);
		var headingTextTargetY:Int = 4;
		headingText.alpha = 0;
		headingText.x = (FlxG.width - headingText.width) / 2;
		headingText.y = -headingText.height;
		FlxTween.tween(headingText, {alpha: 1, y: headingTextTargetY}, 0.75, {
			ease: FlxEase.cubeOut
		});
		add(headingText);

		menuButtonGroup = new FlxTypedGroup<SuffButton>();
		add(menuButtonGroup);

		for (i in 0...menuItems.length) {
			var button:SuffButton = new SuffButton(0, 0, Language.getPhrase(menuItemLabelKeys[i]), null, null, 300, 120);
			if (i % 2 == 1) {
				button.x = FlxG.width + button.width;
			} else {
				button.x = -button.width;
			}
			button.y = headingTextTargetY
				+ headingText.height
				+ ((FlxG.height - headingTextTargetY - headingText.height) - (button.height + 20) * menuItems.length) / 2
				+ i * (button.height + 20);
			FlxTween.tween(button, {x: (FlxG.width - button.width) / 2}, 0.75, {
				ease: FlxEase.cubeOut,
				startDelay: i * 0.1
			});
			button.onClick = function() {
				buttonFunction(menuItems[i]);
			}
			menuButtonGroup.add(button);
		}

		var texts:Array<String> = [
			Language.getPhrase('gamemode.${Gameplay.currentGamemode.id}.name'),
			Language.getPhrase('gameType.' + (Gameplay.isMultiplayer() ? 'multiplayer' : 'singleplayer')),
			Language.getPhrase('pauseMenu.details.players', [Gameplay.selectedCharacterList.length])
		];
		for (num => txt in texts) {
			var text:FlxText = new FlxText(0, 0, txt, 32);
			text.x = FlxG.width;
			text.y = FlxG.height - (text.height * texts.length) - 32 - ScreenSafeArea.Y + num * text.height;
			FlxTween.tween(text, {x: FlxG.width - text.width - 32 - ScreenSafeArea.X}, 1, {
				startDelay: num * 0.1,
				ease: FlxEase.quintOut
			});
			add(text);
		}
	}

	var holdTime:Float = 0;

	function buttonFunction(daSelected:String) {
		if (timePassedOnSubState < 0.25) // Prevent Insta-Unpausing
			return;
		switch (daSelected.toLowerCase()) {
			case 'resume':
				PlayState.instance.isPaused = false;
				PlayState.instance.resumeGame();
				FlxG.camera.followLerp = usedFollowLerp;
				FlxG.sound.music.volume = Preferences.data.musicVolume;
				close();
				if (resetMusic) {
					SuffState.playMusic(PlayState.instance.stage.data.music);
				}
			case 'restart':
				restartGame();
			case 'options':
				OptionsSubState.notInGame = false;
				openSubState(new OptionsSubState());
			case 'exit':
				Achievements.enabled = true;
				SuffState.switchState(new MainMenuState(), TILES, true);
				SuffState.playMusic('null');
				FlxG.camera.followLerp = 0;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			buttonFunction('RESUME');
		}
	}

	public static function restartGame(noTrans:Bool = true) {
		if (FlxG.keys.pressed.SHIFT) PlayState.hasSeenStartCutscene = false;
		SuffState.resetState();
	}

	override function destroy() {
		pauseMusic.pause();
		super.destroy();
	}
}
