package ui.objects;

import backend.typedefs.CharacterData;

class CharacterCard extends SuffButton {
	public var characterData:CharacterData;
	public var designatedPlayer:Null<Int> = null;
	public var holdAnim:Bool = false;

	var bg:FlxSprite;
	var outline:FlxSprite;
	var charSprite:FlxSprite;
	var charNameText:FlxText;

	public function new(x:Float, y:Float, character:CharacterData) {
		super(x, y, null, null, null, Constants.CHARACTER_CARD_DIMENSIONS[0], Constants.CHARACTER_CARD_DIMENSIONS[1], false);

		this.characterData = character;

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menus/characterSelect/cards/${characterData.id}/bg'));
		add(bg);

		outline = new FlxSprite().loadGraphic(Utilities.makeBorder(bg.width, bg.height));
		add(outline);

		charSprite = new FlxSprite();
		charSprite.frames = Paths.sparrowAtlas('ui/menus/characterSelect/cards/${characterData.id}/character');
		charSprite.animation.addByPrefix('idle', 'idle');
		charSprite.animation.addByPrefix('selected', 'selected', 24, false);
		charSprite.animation.play('idle');
		charSprite.animation.onFinish.add(function(animName:String) {
			if (animName == 'selected' && charSprite.animation.curAnim.reversed) {
				charSprite.animation.play('idle', true);
			}
		});
		add(charSprite);

		var key = characterData.cardDisplayedKey != null ? characterData.cardDisplayedKey : 'character.${characterData.id}.name';
		charNameText = new FlxText(6, 6, width - 6 * 2, Language.getPhrase(key).toUpperCase());
		charNameText.setFormat(Paths.font('small'), 32, FlxColor.WHITE);
		add(charNameText);
	}

	public function playAnim(name:String, forced:Bool = false, reversed:Bool = false, firstFrame:Int = 0) {
		charSprite.animation.play(name, forced, reversed, firstFrame);
	}

	public function setScale(x:Float, y:Float) {
		btnBG.setGraphicSize(Std.int(width * x), Std.int(height * y));
		btnBG.updateHitbox();
		for (item in [bg, outline, charSprite]) {
			item.scale.set(x, y);
			item.updateHitbox();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		outline.visible = this.hovered;

		btnBG.visible = false;
		btnOutline.visible = false;

		if (holdAnim) {
			charSprite.animation.play(charSprite.animation.curAnim.name, true, false, charSprite.animation.curAnim.frames.length - 1);
		}
	}
}
