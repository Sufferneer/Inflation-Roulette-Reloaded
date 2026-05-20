package utilities.substates;

import ui.objects.SuffBox;

class ErrorPrompt extends SuffSubState {
	static final boxWidth:Int = 640;
	public function new(message:String, ?okFunction:Void->Void = null) {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		var messageTxt:FlxText = new FlxText(0, 0, boxWidth - 64, Language.getPhrase('utilitiesMenu.error.prompt') + '\n\n' + Language.getPhrase(message), 32);
		messageTxt.alignment = LEFT;

		var box:SuffBox = new SuffBox(0, 0, boxWidth, messageTxt.height + 196);
		box.screenCenter();
		box.bgColor = 0xFFFF4040;
		box.outlineColor = 0xFF800060;
		messageTxt.x = box.x + 32;
		messageTxt.y = box.y + 32;

		add(box);
		add(messageTxt);

		var okButton:SuffButton = new SuffButton(box.x + 32, box.y, Language.getPhrase('menu.ok'), 272);
		okButton.screenCenter(X);
		okButton.y = box.y + box.height - okButton.height - 32;
		okButton.btnBGColor = 0xFFFF4040;
		okButton.btnBGColorHovered = okButton.btnBGColorClicked = 0xFFFF8080;
		okButton.btnOutlineColor = 0xFF800060;
		okButton.btnOutlineColorHovered = okButton.btnOutlineColorClicked = 0xFFFFFFFF;
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
