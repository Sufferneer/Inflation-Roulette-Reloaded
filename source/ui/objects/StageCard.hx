package ui.objects;

class StageCard extends SuffButton {
	var bg:FlxSprite;
	var outline:FlxSprite;
	var stageID:String = 'reloaded';

	public function new(x:Float, y:Float, stageID:String) {
		super(x, y, null, null, null, 320, 180, false);

		this.stageID = stageID;

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menus/characterSelect/stages/$stageID'));
		add(bg);

		outline = new FlxSprite().loadGraphic(Utilities.makeBorder(bg.width, bg.height, 5, 0xFFFFFFFF));
		add(outline);
	}

	override function update(elapsed:Float) {
		outline.visible = this.visible && hovered;
		super.update(elapsed);
	}
}
