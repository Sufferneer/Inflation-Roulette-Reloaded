package ui.objects;

import tjson.TJSON as Json;
import backend.Filler;

class FillerCard extends SuffButton {
	public var filler:Filler;

	var bg:FlxSprite;
	var outline:FlxSprite;
	var charNameText:FlxText;

	public function new(x:Float, y:Float, filler:Filler) {
		super(x, y, null, null, null, Constants.CHARACTER_CARD_DIMENSIONS[0], Constants.CHARACTER_CARD_DIMENSIONS[1], false);

		this.filler = filler;

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menus/characterSelect/fillers/${filler.id}'));
		add(bg);

		outline = new FlxSprite().loadGraphic(Utilities.makeBorder(bg.width, bg.height));
		add(outline);

		charNameText = new FlxText(6, 6, width - 6 * 2, Language.getPhrase('filler.${filler.id}.name').toUpperCase());
		charNameText.setFormat(Paths.font('small'), 32, FlxColor.WHITE);
		add(charNameText);
	}

	public function setScale(x:Float, y:Float) {
		btnBG.setGraphicSize(Std.int(width * x), Std.int(height * y));
		btnBG.updateHitbox();
		for (item in [bg, outline]) {
			item.scale.set(x, y);
			item.updateHitbox();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		outline.visible = this.hovered;

		btnBG.visible = false;
		btnOutline.visible = false;
	}
}
