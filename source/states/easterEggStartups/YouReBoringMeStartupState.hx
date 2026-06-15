package states.easterEggStartups;
import ui.objects.SuffVideoSprite;

class YouReBoringMeStartupState extends SuffState {
	var allowToSkip:Bool = false;
	var video:SuffVideoSprite;

	override function create() {
		super.create();

		Window.setTitle('DO YOU WANT TO PLAY WITH ME?');

		video = new SuffVideoSprite(0, 0);
		video.onFormat(function() {
			video.setGraphicSize(640);
			video.updateHitbox();
			video.screenCenter();
			video.volume = Preferences.data.musicVolume;
		});
		video.onEnd(function() {
			skipIntro();
		});
		add(video);

		if (video.load(Paths.video('obituary'))) {
			video.start();
			allowToSkip = true;
		}
	}

	function skipIntro() {
		if (!allowToSkip)
			return;

		video.skip();

		FlxTransitionableState.skipNextTransIn = true;
		SuffState.switchState(new MainMenuState());
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit') || FlxG.mouse.justPressed) {
			skipIntro();
		}
	}
}
