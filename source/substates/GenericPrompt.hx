package substates;

import ui.objects.SuffBox;

class GenericPrompt extends SuffSubState {
	public function new(message:String, ?okFunction:Void->Void = null, boxWidth:Int = 640) {
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

		var okButton:SuffButton = new SuffButton(box.x + 32, box.y, Language.getPhrase('menu.ok'), 272);
		okButton.screenCenter(X);
		okButton.y = box.y + box.height - okButton.height - 32;
		okButton.onClick = function() {
			if (okFunction != null)
				okFunction();
			close();
		}
		add(okButton);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
