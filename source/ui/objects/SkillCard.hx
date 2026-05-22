package ui.objects;

import backend.Skill;

class SkillCard extends SuffButton {
	public var skill:Skill;
	var skillTitle:FlxText;
	var skillDescription:FlxText;
	var skillCost:FlxText;
	var skillIcon:GameIcon;
	
	var skillBorder:FlxSprite;

	var costIcon:GameIcon;

	public var notEnoughConfidence(default, set):Bool = true;

	public function new(x:Float, y:Float, skill:Skill) {
		this.skill = skill;
		var usedImage = Paths.image('ui/skillCard');
		super(x, y, null, usedImage, null, usedImage.width, usedImage.height, false);

		skillBorder = new FlxSprite().loadGraphic(Utilities.makeBorder(usedImage.width, usedImage.height, 4));
		add(skillBorder);

		skillIcon = new GameIcon(5, 5, 'skills/${skill.id}', 90);
		skillIcon.alpha = 0.75;
		add(skillIcon);

		skillTitle = new FlxText(usedImage.height, 5, usedImage.width - usedImage.height - 6, Language.getPhrase('skill.${skill.id}.name'));
		skillTitle.setFormat(Paths.font('default'), 32, FlxColor.WHITE);

		skillDescription = new FlxText(skillTitle.x, skillTitle.y + skillTitle.height, usedImage.width - usedImage.height - 6,
			Language.getPhrase('skill.${skill.id}.description'));
		skillDescription.setFormat(Paths.font('small'), 16, FlxColor.WHITE);
		skillDescription.alpha = 0.5;

		costIcon = new GameIcon(usedImage.height, usedImage.height - 35, 'stats/confidence', 32);
		costIcon.color = 0xFF4A4399;

		skillCost = new FlxText(usedImage.height + costIcon.width + 2, costIcon.y, 0, '' + skill.cost);
		skillCost.setFormat(Paths.font('default'), 32, costIcon.color);
		skillCost.y = costIcon.y + (costIcon.height - skillCost.height) / 2;

		add(skillTitle);
		add(skillDescription);
		add(costIcon);
		add(skillCost);

		// skillCost.visible = costIcon.visible = (skill.cost > 0);
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);

		skillBorder.visible = hovered;
	}

	private function set_notEnoughConfidence(value:Bool):Bool{
		notEnoughConfidence = value;
		this.disabled = notEnoughConfidence;
		if (notEnoughConfidence) {
			this.btnIcon.color = 0xFF808080;
			this.alpha = 0.6;
			skillCost.text = '${skill.cost} · </>';
			costIcon.color = skillCost.color = 0xFFC00000;
		} else {
			this.btnIcon.color = 0xFFFFFFFF;
			this.alpha = 1;
			skillCost.text = '${skill.cost}';
			costIcon.color = skillCost.color = 0xFF4A4399;
		}
		return value;
	}
}