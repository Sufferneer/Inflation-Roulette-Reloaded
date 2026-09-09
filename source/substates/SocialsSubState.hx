package substates;

import states.extras.GalleryMainMenuState;
import states.extras.JukeboxState;
import ui.objects.SuffIconButton;
import ui.objects.BackgroundButton;

class SocialsSubState extends SuffSubState {
	var exitButton:SuffIconButton;

	public function new() {
		super();

		WindowUtil.setTitle(Language.getPhrase('socialsMenu.windowDisplay'));

		persistentUpdate = false;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.75}, 0.5);
		add(bg);

		final outlineThickness:Int = 4;
		var box:FlxSprite = new FlxSprite().makeGraphic(840 + outlineThickness * 3, 360 + outlineThickness * 2, 0xFF008FB5);
		box.screenCenter();
		add(box);

		var kofiButton = new BackgroundButton(box.x + outlineThickness, box.y + outlineThickness, 'socialsMenu.kofi', 'socials/kofi');
		kofiButton.onClick = function() {
			openSubState(new HyperlinkPrompt('https://ko-fi.com/nicklysuffer'));
		}
		kofiButton.tooltipText = Language.getPhrase('socialsMenu.kofi.tooltip');
		add(kofiButton);

		var discordButton = new BackgroundButton(box.x + kofiButton.width + outlineThickness * 2, box.y + outlineThickness, 'socialsMenu.discord', 'socials/discord');
		discordButton.onClick = function() {
			openSubState(new HyperlinkPrompt('https://discord.gg/gXXzbYsfra'));
		}
		discordButton.tooltipText = Language.getPhrase('socialsMenu.discord.tooltip');
		add(discordButton);

		var headingText:FlxText = new FlxText(0, 0, 0, Language.getPhrase('socialsMenu.title'), 48);
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
