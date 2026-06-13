package substates;
import ui.objects.GitHubButton;

class RecordingWarning extends SuffSubState {
	public function new() {
		super();

		persistentUpdate = false;

		FlxG.sound.music.stop();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		var text:FlxText = new FlxText(0, 0, FlxG.width * 0.75, "We have detected a recording program running in the background.\n\nIf you are a fetish YouTuber, please note that profiting off minors watching my 18+ GAME definitely isn't someone with a functioning moral compass would do. So please, if you're wishing to do your shitty job of content farming, do it with some other game.\n\nFor normal players, if you wish to provide footage for bug reports, please provide screenshots and/or crash reports instead.", 32);
		text.alignment = JUSTIFY;
		text.screenCenter();

		var githubButton:GitHubButton = new GitHubButton(0, 0, 'issues');
		githubButton.screenCenter();

		text.y = (FlxG.height - (text.height + 20 + githubButton.height)) / 2;
		githubButton.y = text.y + text.height + 20;

		add(text);
		add(githubButton);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}

	function exitMenu() {
		Sys.exit(1);
	}
}
