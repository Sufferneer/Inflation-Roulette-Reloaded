package ui.objects;

import backend.typedefs.AchievementData;
import ui.objects.AchievementIcon;
import objects.particles.Sparkle;

class AchievementPlaque extends SuffButton {
	var plaqueFrame:FlxSprite;
	var icon:AchievementIcon;
	var spawnSparkles:Bool = false;
	var achievementData:AchievementData;

	public var locked(default, set):Bool = true;
	public function new(x:Float, y:Float, achievement:AchievementData, locked:Bool = true) {
		super(x, y, null, null, null, 160, 160, false);

		this.achievementData = achievement;
		plaqueFrame = new FlxSprite().loadGraphic(Paths.image('ui/menus/achievements/frames/common'));
		plaqueFrame.loadGraphic(Paths.image('ui/menus/achievements/frames/common'), true, Std.int(plaqueFrame.width / 2), Std.int(plaqueFrame.height));
		plaqueFrame.animation.add('false', [0], true);
		plaqueFrame.animation.add('true', [1], true);
		plaqueFrame.animation.play('idle');

		icon = new AchievementIcon(0, 0, achievementData.id, locked);
		icon.x = (plaqueFrame.width - icon.width) / 2;
		icon.y = (plaqueFrame.height - icon.height) / 2;
		
		this.locked = locked;

		add(icon);
		add(plaqueFrame);
	}

	private function set_locked(value:Bool):Bool {
		this.locked = value;
		var frameType = '${achievementData.tier}'.toLowerCase();
		if (locked)
			frameType = 'locked';
		plaqueFrame.loadGraphic(Paths.image('ui/menus/achievements/frames/$frameType'), true, Std.int(plaqueFrame.width), Std.int(plaqueFrame.height));
		plaqueFrame.animation.add('false', [0], true);
		plaqueFrame.animation.add('true', [1], true);
		plaqueFrame.animation.play('$hovered');
		
		icon.loadIconGraphic(achievementData.id, value);
		icon.locked = value;

		return value; 
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		plaqueFrame.animation.play('$hovered');
	}
}
