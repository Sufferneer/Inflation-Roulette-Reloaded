package ui.objects;

import backend.typedefs.CharacterData;
import backend.typedefs.SkillData;
import backend.enums.CharacterSelectSubstring;
import ui.objects.GameIcon;

class CharacterSelectText extends FlxText {
	public function new(x:Float, y:Float) {
		super(x, y);
		setFormat(Paths.getFont('default'), 32, FlxColor.WHITE);

		reloadText();
	}

	public function reloadText(character:CharacterData = null, overlay:String = 'characterSelect.holdCardsToSeeInfo') {
		if (character == null) { // Default character data
			this.text = Language.getPhrase(overlay);
		} else if (character.id == 'random') {
			this.text = Language.getPhrase('character.random.description');
		} else {
			this.text = Language.getPhrase('character.${character.id}.description');
		}
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
