package ui.objects;

import backend.typedefs.AchievementData;
import ui.objects.AchievementIcon;

class TimeBalloon extends FlxSpriteGroup {
	var balloon:FlxSprite;
	var pointer:FlxSprite;
	var text:FlxText;

	public var maxTime:Float = -1;
	public var timeRemaining:Float = -1;
	public var tick:Float = 0;
	
	public function new(x:Float = 0, y:Float = 0, maxTime:Float = -1) {
		super(x, y);
		this.maxTime = maxTime;
		balloon = new FlxSprite().loadGraphic(Paths.getImage('ui/timeBalloon'));
		add(balloon);

		pointer = new FlxSprite().loadGraphic(Paths.getImage('ui/timeBalloonPointer'));
		pointer.setPosition((balloon.width - pointer.width) / 2, pointer.height);
		pointer.origin.y = pointer.height - pointer.width / 2;
		add(pointer);

		text = new FlxText(0, 0, balloon.width, '0:00', 48);
		text.y = (balloon.height - text.height) / 2;
		text.setFormat(Paths.getFont('default'), 48, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		text.borderSize = 4;
		add(text);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		pointer.angle = 360 * timeRemaining / maxTime;
		
		var timeText:String = '';
		var displayedTime = Std.int(timeRemaining);
		if (displayedTime >= 60)
			timeText = FlxStringUtil.formatTime(displayedTime);
		else {
			timeText = '' + Utilities.formatDecimal(timeRemaining, 1);
		}
		if (displayedTime < 10)
			text.color = 0xFF0000;
		else if (displayedTime < timeRemaining * 0.5)
			text.color = 0xFF8080;
		else if (displayedTime < timeRemaining * 0.75)
			text.color = 0xFFC0C0;
		else
			text.color = 0xFFFFFF;
		text.text = timeText;

		var period = FlxMath.bound(FlxMath.remapToRange(timeRemaining, 0, 120, 1 / 16, 4.0), 1 / 16, 4.0);
		tick += elapsed;
		if (tick >= period)
			tick = 0;
		var amplitude = FlxMath.bound(FlxMath.remapToRange(timeRemaining, 0, 60, 0.05, 0.01), 0.01, 0.05);
		var scale = 1 + Math.pow(Math.sin(tick * Math.PI * 2 / period), 2) * amplitude;
		balloon.scale.set(scale, scale);
	}
}
