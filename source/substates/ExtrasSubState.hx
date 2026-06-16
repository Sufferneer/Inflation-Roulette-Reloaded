package substates;

import ui.objects.SuffIconButton;
import states.extras.JukeboxState;
import states.extras.GalleryMainMenuState;

class ExtrasSubState extends SuffSubState {
	var exitButton:SuffIconButton;

	public function new() {
		super();

		Window.setTitle(Language.getPhrase('extrasMenu.windowDisplay'));

		persistentUpdate = false;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.5}, 0.5);
		add(bg);

		var box:FlxSprite = new FlxSprite().makeGraphic(840, 360, 0xFF008FB5);
		box.screenCenter();
		add(box);

		final outlineThickness:Int = 4;

		var galleryBG:FlxSprite = new FlxSprite(box.x + outlineThickness, box.y + outlineThickness);
		galleryBG.loadGraphic(Paths.image('ui/menus/extras/galleryBG'), true, 420, 360);
		galleryBG.animation.add('selected', [0]);
		galleryBG.animation.add('idle', [1]);
		galleryBG.animation.play('idle');
		galleryBG.clipRect = new FlxRect(0, 0, box.width / 2 - outlineThickness * 1.5, box.height - outlineThickness * 2);
		galleryBG.clipRect = galleryBG.clipRect;
		add(galleryBG);

		var galleryText:FlxText = new FlxText(galleryBG.x, galleryBG.y + galleryBG.height * 0.15, galleryBG.width, Language.getPhrase('extrasMenu.gallery'), 48);
		galleryText.setFormat(Paths.font('default'), 48, 0xFFFFFFFF, CENTER, OUTLINE, 0xFFFFFFFF);
		galleryText.borderSize = 0;
		add(galleryText);

		var galleryButton:SuffButton = new SuffButton(galleryBG.x, galleryBG.y, '', null, null, galleryBG.width, galleryBG.height, false);
		galleryButton.onHover = function() {
			galleryBG.animation.play('selected');
			galleryText.borderSize = 3;
			galleryText.color = 0xFF000000;
		}
		galleryButton.onIdle = function() {
			galleryBG.animation.play('idle');
			galleryText.borderSize = 0;
			galleryText.color = 0xFFFFFFFF;
		}
		galleryButton.onClick = function() {
			SuffState.switchState(new GalleryMainMenuState(), DEFAULT, true);
		}
		add(galleryButton);

		var jukeboxBG:FlxSprite = new FlxSprite(box.x + box.width / 2 + outlineThickness * 0.5, box.y + outlineThickness);
		jukeboxBG.loadGraphic(Paths.image('ui/menus/extras/jukeboxBG'), true, 420, 360);
		jukeboxBG.animation.add('selected', [0]);
		jukeboxBG.animation.add('idle', [1]);
		jukeboxBG.animation.play('idle');
		jukeboxBG.clipRect = new FlxRect(0, 0, box.width / 2 - outlineThickness * 1.5, box.height - outlineThickness * 2);
		jukeboxBG.clipRect = jukeboxBG.clipRect;
		add(jukeboxBG);

		var jukeboxText:FlxText = new FlxText(jukeboxBG.x, jukeboxBG.y + jukeboxBG.height * 0.15, jukeboxBG.width, Language.getPhrase('extrasMenu.jukebox'), 48);
		jukeboxText.setFormat(Paths.font('default'), 48, 0xFFFFFFFF, CENTER, OUTLINE, 0xFFFFFFFF);
		jukeboxText.borderSize = 0;
		add(jukeboxText);

		var jukeboxButton:SuffButton = new SuffButton(jukeboxBG.x, jukeboxBG.y, '', null, null, jukeboxBG.width, jukeboxBG.height, false);
		jukeboxButton.onHover = function() {
			jukeboxBG.animation.play('selected');
			jukeboxText.borderSize = 3;
			jukeboxText.color = 0xFF000000;
		}
		jukeboxButton.onIdle = function() {
			jukeboxBG.animation.play('idle');
			jukeboxText.borderSize = 0;
			jukeboxText.color = 0xFFFFFFFF;
		}
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

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}

	function exitMenu() {
		persistentUpdate = true;
		Window.setTitle(Language.getPhrase('mainMenu.windowDisplay'));
		close();
	}
}
