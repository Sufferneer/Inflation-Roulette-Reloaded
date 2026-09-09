package substates;

import ui.objects.SuffIconButton;
import states.extras.JukeboxState;
import states.extras.GalleryMainMenuState;
import ui.objects.BackgroundButton;

class ExtrasSubState extends SuffSubState {
	var exitButton:SuffIconButton;

	public function new() {
		super();

		WindowUtil.setTitle(Language.getPhrase('extrasMenu.windowDisplay'));

		persistentUpdate = false;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.75}, 0.5);
		add(bg);

		final outlineThickness:Int = 4;
		var box:FlxSprite = new FlxSprite().makeGraphic(840 + outlineThickness * 3, 360 + outlineThickness * 2, 0xFF008FB5);
		box.screenCenter();
		add(box);

		var galleryButton = new BackgroundButton(box.x + outlineThickness, box.y + outlineThickness, 'extrasMenu.gallery', 'extras/gallery');
		galleryButton.onClick = function() {
			SuffState.switchState(new GalleryMainMenuState(), DEFAULT, true);
		}
		add(galleryButton);

		var jukeboxButton = new BackgroundButton(box.x + galleryButton.width + outlineThickness * 2, box.y + outlineThickness, 'extrasMenu.jukebox', 'extras/jukebox');
		jukeboxButton.onClick = function() {
			SuffState.switchState(new JukeboxState(), DEFAULT, true);
		}
		add(jukeboxButton);

		var headingText:FlxText = new FlxText(0, 0, 0, Language.getPhrase('extrasMenu.title'), 48);
		headingText.alpha = 0;
		headingText.x = (FlxG.width - headingText.width) / 2;
		headingText.y = -headingText.height;
		FlxTween.tween(headingText, {alpha: 1, y: 4}, 0.75, {
			ease: FlxEase.cubeOut
		});
		add(headingText);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}

	function exitMenu() {
		persistentUpdate = true;
		WindowUtil.setTitle(Language.getPhrase('mainMenu.windowDisplay'));
		close();
	}
}
