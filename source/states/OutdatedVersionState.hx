package states;

class OutdatedVersionState extends SuffState {
	var exiting:Bool = false;
	public static var latestVersion:String = '';

	override function create() {
		super.create();

		Window.setTitle(Language.getPhrase('outdatedVersionMenu.windowDisplay'));

		var heading:FlxText = new FlxText(0, 0, FlxG.width * (3 / 4), Language.getPhrase('outdatedVersionMenu.heading'), 64);
		heading.alignment = 'center';
		var text:FlxText = new FlxText(0, 0, heading.width, Language.getPhrase('outdatedVersionMenu.text', [FlxG.stage.application.meta.get('version'), latestVersion]), 32);
		text.alignment = 'center';
		var updateButton:SuffButton = new SuffButton(0, 0, Language.getPhrase('outdatedVersionMenu.update'), 250, 100);
		updateButton.btnBGColor = updateButton.btnBGColorHovered = updateButton.btnBGColorClicked = 0xFF000000;
		updateButton.btnOutlineColor = updateButton.btnOutlineColorHovered = updateButton.btnOutlineColorClicked = 0xFF00FF00;
		updateButton.btnTextColor = updateButton.btnTextColorHovered = updateButton.btnTextColorClicked = 0xFF00FF00;
		updateButton.onClick = function() {
			Utilities.browserLoad('https://nicklysuffer-da.itch.io/inflation-roulette-reloaded');
		}
		var dismissButton:SuffButton = new SuffButton(0, 0, Language.getPhrase('outdatedVersionMenu.dismiss'), 250, 100);
		dismissButton.btnBGColor = dismissButton.btnBGColorHovered = dismissButton.btnBGColorClicked = 0xFF000000;
		dismissButton.btnOutlineColor = dismissButton.btnOutlineColorHovered = dismissButton.btnOutlineColorClicked = 0xFFFFFFFF;
		dismissButton.onClick = function() {
			exitMenu();
		}
		
		heading.screenCenter();
		heading.y = (FlxG.height - (heading.height + text.height + 32 + 20 + updateButton.height)) / 2;
		text.screenCenter();
		text.y = heading.y + heading.height;
		updateButton.x = (FlxG.width - (updateButton.width + 20 + dismissButton.width)) / 2;
		dismissButton.x = updateButton.x + updateButton.width + 20;
		updateButton.y = dismissButton.y = text.y + text.height + 32 + 20;
		
		add(heading);
		add(text);
		add(updateButton);
		add(dismissButton);
	}

	function exitMenu() {
		if (exiting)
			return;
		exiting = true;
		FlxTransitionableState.skipNextTransIn = true;
		SuffState.switchState(new InitStartupState());
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}
}
