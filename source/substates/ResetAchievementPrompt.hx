package substates;

import states.AchievementsState;
import backend.Gameplay;
import states.PlayState;

class ResetAchievementPrompt extends SuffSubState {
	var bg:FlxSprite;
	var messageText:FlxText;
	var confirmButton:SuffButton;
	var cancelButton:SuffButton;

	public function new(id:String) {
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.825;
		bg.scrollFactor.set();
		add(bg);

		messageText = new FlxText(0, 0, FlxG.width * 0.75, Language.getPhrase('resetAchievementMenu.prompt', [Language.getPhrase('achievement.$id.name')]), 48);
		messageText.alignment = CENTER;
		messageText.screenCenter();
		messageText.scrollFactor.set();

		confirmButton = new SuffButton(0, 0, Language.getPhrase('menu.confirm'), null, null, 300, 100);
		confirmButton.onClick = function() {
			SuffState.playUISound(Paths.sound('ui/achievements/ominous'), 0.6, 1);
			Achievements.resetProgress(id);
			AchievementsState.instance.lockPlaque(id);
			AchievementsState.instance.changeAchievementText(Achievements.achievementsList[id], Achievements.curProgress[id]);
			close();
		};
		confirmButton.btnBGColor = 0xFFFF4040;
		confirmButton.btnBGColorHovered = confirmButton.btnBGColorClicked = 0xFFFF8080;
		confirmButton.btnOutlineColor = 0xFF800060;
		confirmButton.btnOutlineColorHovered = confirmButton.btnOutlineColorClicked = 0xFFFFFFFF;
		confirmButton.scrollFactor.set();

		cancelButton = new SuffButton(0, 0, Language.getPhrase('menu.cancel'), null, null, 300, 100);
		cancelButton.onClick = function() {
			close();
		};
		cancelButton.scrollFactor.set();

		add(messageText);
		add(confirmButton);
		add(cancelButton);

		messageText.y = (FlxG.height - (messageText.height + 20 + confirmButton.height)) / 2;
		cancelButton.x = (FlxG.width - (cancelButton.width + 20 + confirmButton.width)) / 2;
		confirmButton.x = cancelButton.x + cancelButton.width + 20;
		confirmButton.y = cancelButton.y = messageText.y + messageText.height + 20;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit'))
			close();
	}
}
