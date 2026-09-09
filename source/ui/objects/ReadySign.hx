package ui.objects;

import shaders.OutlineShader;

class ReadySign extends SuffButton {
	var sign:FlxSprite;
	var chainLeft:FlxSprite;
	var chainRight:FlxSprite;
	
	static var outlineShader:OutlineShader;

	var currentFrame:Float = 0;
	var frameDirection:Float = 0;
	static final firstFrame:Float = 0;
	static final lastFrame:Float = 11;
	static final frameRate:Float = 24;

	public function new(startDisabled:Bool = true) {
		super((FlxG.width - 230) / 2, 0, null, null, null,230, 160, false);

		initShader();

		chainLeft = new FlxSprite().loadGraphic(Paths.getImage('ui/menus/characterSelect/readySign/chain'));
		chainLeft.shader = outlineShader;
		add(chainLeft);
		chainRight = new FlxSprite().loadGraphic(Paths.getImage('ui/menus/characterSelect/readySign/chain'));
		chainRight.shader = outlineShader;
		add(chainRight);
		sign = new FlxSprite().loadGraphic(Paths.getImage('ui/menus/characterSelect/readySign/sign'));
		sign.shader = outlineShader;
		add(sign);

		disabled = startDisabled;
		sign.visible = chainLeft.visible = chainRight.visible = !startDisabled;
		if (!startDisabled)
			moveSign(true);
	}

	public function moveSign(moveIn:Bool = true) {
		frameDirection = moveIn ? 1 : -1;
		this.disabled = !moveIn;
		sign.visible = chainLeft.visible = chainRight.visible = true;
	}
	
	static function initShader() {
		if (!Preferences.data.enableGLSL || outlineShader != null) return;
		outlineShader = new OutlineShader(0xFFFFFFFF, 4);
		outlineShader.lineBoil = true;
		outlineShader.lineBoilStep = 6;
		outlineShader.enabled = false;
	}
	
	function animate(frameDecimal:Float) {
		var frame = Std.int(frameDecimal);
		var signPos:FlxPoint = FlxPoint.get(0, 0);
		var chainLeftPos:FlxPoint = FlxPoint.get(0, 0);
		var chainRightPos:FlxPoint = FlxPoint.get(0, 0);
		if (frame == 0) {
			sign.visible = chainLeft.visible = chainRight.visible = false;
			return;
		}
		sign.visible = chainLeft.visible = chainRight.visible = true;
		switch (frame) {
			case 1 | 2:
				signPos.set(0, -95);
				sign.angle = 25;
				chainLeftPos.set(55, -270);
				chainRightPos.set(190, -205);
			case 3 | 4:
				signPos.set(-10, -30);
				sign.angle = 9;
				chainLeftPos.set(25, -190);
				chainRightPos.set(175, -165);
			case 5 | 6:
				signPos.set(-3, 47);
				sign.angle = 0;
				chainLeftPos.set(25, -105);
				chainRightPos.set(175, -105);
			case 7 | 8:
				signPos.set(2, 46);
				sign.angle = -4;
				chainLeftPos.set(25, -100);
				chainRightPos.set(175, -115);
			case 9 | 10:
				signPos.set(-1, 39);
				sign.angle = -1;
				chainLeftPos.set(24, -109);
				chainRightPos.set(174, -111);
			case 11:
				signPos.set(0, 38);
				sign.angle = 0;
				chainLeftPos.set(25, -110);
				chainRightPos.set(175, -110);
		}
		sign.setPosition(this.x + signPos.x, this.y + signPos.y);
		chainLeft.setPosition(this.x + chainLeftPos.x, this.y + chainLeftPos.y);
		chainRight.setPosition(this.x + chainRightPos.x, this.y + chainRightPos.y);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (outlineShader != null) {
			outlineShader.update(elapsed);
			outlineShader.enabled = (!disabled && hovered);
		}

		currentFrame = FlxMath.bound(currentFrame + elapsed * frameRate * frameDirection, firstFrame, lastFrame);
		animate(currentFrame);
	}
}
