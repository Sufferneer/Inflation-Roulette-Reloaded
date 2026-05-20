package utilities.substates;

import ui.objects.SuffBox;

class ChoicePrompt extends SuffSubState {
	public function new(message:String, ?yesFunction:Void->Void = null, ?noFunction:Void->Void = null, boxWidth:Int = 640) {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		var messageTxt:FlxText = new FlxText(0, 0, boxWidth - 64, Language.getPhrase(message), 32);
		messageTxt.alignment = LEFT;

		var box:SuffBox = new SuffBox(0, 0, boxWidth, messageTxt.height + 196);
		box.screenCenter();
		messageTxt.x = box.x + 32;
		messageTxt.y = box.y + 32;

		add(box);
		add(messageTxt);

		var yesButton:SuffButton = new SuffButton(box.x + 32, box.y, Language.getPhrase('menu.yes'), boxWidth / 2 - 32 - 16);
		yesButton.y = box.y + box.height - yesButton.height - 32;
		yesButton.onClick = function() {
			if (yesFunction != null)
				yesFunction();
			close();
		}
		add(yesButton);

		var noButton:SuffButton = new SuffButton(0, 0, Language.getPhrase('menu.no'), boxWidth / 2 - 32 - 16);
		noButton.x = box.x + box.width - noButton.width - 32;
		noButton.y = box.y + box.height - noButton.height - 32;
		noButton.onClick = function() {
			if (noFunction != null)
				noFunction();
			close();
		}
		add(noButton);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
