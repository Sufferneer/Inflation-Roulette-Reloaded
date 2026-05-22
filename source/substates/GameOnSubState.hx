package substates;

import backend.CharacterManager;
import states.PlayState;

class GameOnSubState extends SuffSubState {
	var slashBGDim:FlxSprite;
	var slashBG:FlxSprite;
	var gameOn:FlxText;

	public function new(nextState) {
		super();
		
		SuffState.playMusic('characterSelectEnd', 1, true);

		slashBGDim = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		slashBGDim.alpha = 0;
		add(slashBGDim);

		slashBG = new FlxSprite();
		slashBG.frames = Paths.sparrowAtlas('ui/menus/characterSelect/slashBG');
		slashBG.animation.addByPrefix('idle', 'idle', 24, false);
		slashBG.screenCenter();
		slashBG.scale.set(FlxG.width / Constants.ORIGINAL_FLXG_WIDTH, 0.75);
		slashBG.alpha = 0;
		add(slashBG);

		gameOn = new FlxText(0, 0, 0, Language.getPhrase('gameOn.text'));
		gameOn.setFormat(Paths.font('default'), 256, FlxColor.WHITE);
		while (gameOn.width > FlxG.width - 200) {
			gameOn.size -= 16;
			slashBG.scale.y = gameOn.size / 256 * 0.75;
		}
		gameOn.alpha = 0;
		gameOn.screenCenter();
		gameOn.scale.set(0, 0);
		add(gameOn);

		FlxTween.tween(slashBGDim, {alpha: 0.5}, 0.5);
		slashBG.alpha = 0.25;
		slashBG.animation.play('idle');
		FlxTween.tween(gameOn, {alpha: 1, 'scale.x': 1, 'scale.y': 1}, 1, {
			ease: FlxEase.bounceOut,
			onComplete: function(_) {
				new FlxTimer().start(1, function(_) {
					SuffState.switchState(nextState, DEFAULT, true);
				});
			}
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
