package objects.particles;

class HoseboundChain extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0, playerIndex:Int = 0) {
		super(x, y);
		loadGraphic(Paths.getImage('game/particles/hoseboundChain'));
		this.color = Constants.PLAYER_COLORS[playerIndex];
		this.alpha = 0.25;
		this.offset.x += this.width / 2;
		this.offset.y += this.height / 2;
		this.angle = FlxG.random.int(-180, 180);
		this.angularVelocity = FlxG.random.int(-3, 3, [0]) * 360;
		FlxTween.tween(this, {alpha: 0}, 0.5, {
			startDelay: 0.5,
			onComplete: function(_) {
				FlxG.state.remove(this, true);
				this.destroy();
			}
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
