package objects.particles;

class PlayerIndicator extends FlxSpriteGroup {
	var arrow:FlxSprite;
	var text:FlxText;
	
	public function new(x:Float = 0, y:Float = 0, player:Int = 0, alt:Bool = false) {
		arrow = new FlxSprite();
		arrow.loadGraphic(Paths.image('game/particles/playerIndicator'));
		arrow.color = Constants.PLAYER_COLORS[player];

		text = new FlxText(Language.getPhrase('game.playerIndicator.player', ['${player + 1}']), 64);
		if (alt) {
			text.text = Language.getPhrase('game.playerIndicator.you');
		}
		text.setPosition((arrow.width - text.width) / 2, (arrow.height - text.height) / 2);
		text.setBorderStyle(OUTLINE, 0xFF000000, 4);

		super(x, y);
		add(arrow);
		add(text);
		offset.x += width / 2;
		offset.y += height;

		FlxTween.tween(this, {alpha: 0}, 1, {startDelay: 3, onComplete: function(_) {
			this.destroy();
		}});
	}
	
	var tick:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		tick += elapsed;
		offset.y = height + Math.pow(Math.sin(tick * Math.PI) , 2) * 16;
	}
}
