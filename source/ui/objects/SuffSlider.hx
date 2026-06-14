package ui.objects;

enum SuffSliderScaling {
	LINEAR;
	LOGARITHMIC;
}

class SuffSlider extends FlxSpriteGroup {
	public var currentValue:Float;
	public var onChangeCallback:Float->Void;
	public var onScrollCallback:Float->Void;
	public var displayFunction:Float->String;
	public var name:String = '';
	public var hovered:Bool = false;
	public var pressed:Bool = false;
	public var range:Array<Float> = [0.0, 1.0];
	public var step:Float = 0.1;
	public var scaling:SuffSliderScaling = LINEAR;

	var outline:FlxSprite;
	var parent:FlxSprite;

	public var tooltipText:String = '';

	var displayText:FlxText;
	var minX:Float = 0;
	var maxX:Float = 0;
	var parentActualX:Float = 0;

	public function new(x:Float, y:Float, callback:Float->Void, rangeMin:Null<Float> = null, rangeMax:Null<Float> = null, step:Float = 0.05,
			displayFunction:Float->String = null, defaultValue:Float = 0, scrollCallback:Float->Void = null, scaling:SuffSliderScaling = LINEAR) {
		super(x, y);
		onChangeCallback = callback;
		if (scrollCallback != null)
			onScrollCallback = scrollCallback;
		this.displayFunction = function(value:Float):String {
			return Math.round(value * 100) + '%';
		}
		if (displayFunction != null)
			this.displayFunction = displayFunction;
		this.currentValue = defaultValue;
		this.step = step;
		if (rangeMin != null)
			this.range[0] = rangeMin;
		if (rangeMax != null)
			this.range[1] = rangeMax;
		// trace(range);
		this.scaling = scaling;

		outline = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/slider/bar'));

		parent = new FlxSprite();
		parent.frames = Paths.sparrowAtlas('ui/menus/options/slider/switch');
		parent.animation.addByPrefix('idle', 'idle', 24, true);
		parent.animation.addByPrefix('hovered', 'hovered', 24, true);

		displayText = new FlxText(0, outline.height, outline.width, '');
		displayText.setFormat(Paths.font('default'), 32, FlxColor.WHITE, CENTER);

		minX = outline.x;
		maxX = outline.x + outline.width - parent.width;
		parent.x = Utilities.lerp(minX, maxX, Utilities.invLerp(range[0], range[1], defaultValue), scaling == LOGARITHMIC ? 0.5 : 1);
		parentActualX = parent.x;

		add(outline);
		add(parent);
		add(displayText);

		recalculateValue(false);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function setDisplayTextText(val:Float) {
		displayText.text = displayFunction(val);
	}

	function recalculateValue(callback:Bool = true) {
		var leActualPercent = Utilities.invLerp(minX, maxX, parentActualX);
		var leActualValue = Utilities.lerp(range[0], range[1], leActualPercent, scaling == LOGARITHMIC ? 2 : 1);
		var leStep = step;
		var leSnappedValue = Math.round(leActualValue / leStep) * leStep;
		var leSnappedPercent = Utilities.invLerp(range[0], range[1], leSnappedValue);
		parent.x = this.x + Utilities.lerp(minX, maxX, leSnappedPercent, scaling == LOGARITHMIC ? 0.5 : 1);
		currentValue = FlxMath.lerp(range[0], range[1], leSnappedPercent);
		if (callback)
			onChangeCallback(currentValue);
		setDisplayTextText(currentValue);
		// trace(currentValue);
	}

	function snapSlider() {
		var leActualPercent = Utilities.invLerp(minX, maxX, parentActualX);
		var leActualValue = Utilities.lerp(range[0], range[1], leActualPercent, scaling == LOGARITHMIC ? 2 : 1);
		var leStep = step;
		var leSnappedValue = Math.round(leActualValue / leStep) * leStep;
		var leSnappedPercent = Utilities.invLerp(range[0], range[1], leSnappedValue);
		parent.x = this.x + parentActualX;

		if (onScrollCallback != null) {
			onScrollCallback(leSnappedValue);
		}
		setDisplayTextText(leSnappedValue);
	}

	function updateSlider() {
		parentActualX += FlxG.mouse.deltaScreenX;
		if (parentActualX < minX) {
			parentActualX = minX;
		} else if (parentActualX > maxX) {
			parentActualX = maxX;
		}
		snapSlider();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (pressed) {
			updateSlider();
			if (FlxG.mouse.justReleased) {
				pressed = false;
				snapSlider();
				recalculateValue();
			}
		}
		if (FlxG.mouse.overlaps(parent, this.camera) && visible) {
			if (!hovered) {
				SuffState.playUISound(Paths.sound('ui/buttonHover'));
				parent.animation.play('hovered');
				Tooltip.text = tooltipText;
				hovered = true;
			}
			if (FlxG.mouse.pressed) {
				pressed = true;
			}
		} else {
			parent.animation.play('idle');
			if (hovered)
				Tooltip.text = '';
			hovered = false;
		}
	}
}
