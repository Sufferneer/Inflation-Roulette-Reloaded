package utilities.substates;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flash.net.FileFilter;
#if _ALLOW_UTILITIES
import backend.FileDialogHandler;
#end
import openfl.geom.Rectangle;
import openfl.geom.Point;
import utilities.states.AnimationEditorState;
import ui.objects.SuffMarker;
import utilities.states.CharacterCreatorState;
import ui.objects.SuffTextButton;
import ui.objects.SuffSliderOption;
import objects.Character;

class OffsetEditorSubstate extends UtilitiesBaseMenuSubState {
	var sprite:FlxSprite;
	var offsetMarker:SuffMarker;
	var originMarker:SuffMarker;
	var offsetTxt:FlxText;
	var offset:FlxPoint = FlxPoint.get(0, 0);
	var origin:FlxPoint = FlxPoint.get(0, 0);

	var offsets = ['origin', 'overhead', 'mouth', 'navel', 'gunShoot', 'gunSkill'];
	var offsetsAnimation:Map<String, String> = [
		'origin' => 'idle',
		'overhead' => 'idle',
		'mouth' => 'idle',
		'navel' => 'idle',
		'gunShoot' => 'shootBlank',
		'gunSkill' => 'skill',
	];
	var currentOffsetType:String = 'origin';
	var currentPressure:Int = 0;

	public function new() {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		sprite = new FlxSprite();
		reloadSprite();
		sprite.screenCenter();
		add(sprite);

		var leftBorder:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2 - sprite.width / 2), FlxG.height, 0xFF000000);
		leftBorder.alpha = 0.5;

		var rightBorder:FlxSprite = new FlxSprite(leftBorder.width + sprite.width, 0).makeGraphic(Std.int(FlxG.width / 2 - sprite.width / 2), FlxG.height, 0xFF000000);
		rightBorder.alpha = 0.5;

		var upBorder:FlxSprite = new FlxSprite(leftBorder.width, 0).makeGraphic(Std.int(sprite.width), Std.int(FlxG.height / 2 - sprite.height / 2), 0xFF000000);
		upBorder.alpha = 0.5;

		var downBorder:FlxSprite = new FlxSprite(leftBorder.width, upBorder.height + sprite.height).makeGraphic(Std.int(sprite.width), Std.int(FlxG.height / 2 - sprite.height / 2), 0xFF000000);
		downBorder.alpha = 0.5;

		originMarker = new SuffMarker(sprite.x + CharacterCreatorState.spriteData.originPosition[0], sprite.y + CharacterCreatorState.spriteData.originPosition[1]);

		var what = getParticleOffset(currentOffsetType);
		offsetMarker = new SuffMarker(originMarker.x + what.x, originMarker.y + what.y, 0xFFFFFF00);

		add(sprite);
		add(originMarker);
		add(offsetMarker);
		add(leftBorder);
		add(rightBorder);
		add(upBorder);
		add(downBorder);

		for (num => offset in offsets) {
			var button = new SuffButton(rightBorder.x + 32, rightBorder.y + 32 + 80 * num, Language.getPhrase('offsetEditor.offsetType.' + offset), rightBorder.width - 64, 64);
			button.onClick = function() {
				currentOffsetType = offset;
				reloadSprite();
				var what = getParticleOffset(currentOffsetType);
				offsetMarker.setPosition(originMarker.x + what.x, originMarker.y + what.y);
				updateValues();
			}
			add(button);
		}

		var helpTitle:FlxText = new FlxText(32, 32, leftBorder.width - 64, Language.getPhrase('offsetEditor.title'), 32);
		add(helpTitle);
		var helpDesc:FlxText = new FlxText(32, helpTitle.y + helpTitle.height, leftBorder.width - 40, Language.getPhrase('offsetEditor.description'), 16);
		add(helpDesc);
		var pressureSlider = new SuffSliderOption(helpDesc.x, helpDesc.y + helpDesc.height, function(val:Float) {
			currentPressure = Std.int(val);
			reloadSprite();
			var what = getParticleOffset(currentOffsetType);
			offsetMarker.setPosition(originMarker.x + what.x, originMarker.y + what.y);
			updateValues();
		}, 0, CharacterCreatorState.spriteData.maxPressure + 2, 1, function(val:Float) {
			return Language.getPhrase("stats.pressure." + parseAnimationSuffix(Std.int(val)), [], Std.int(val) + '');
		});
		add(pressureSlider);
		offsetTxt = new FlxText(32, 32, leftBorder.width - 64, '[0, 0]', 32);
		offsetTxt.y = FlxG.height - offsetTxt.height - 32;
		add(offsetTxt);

		updateValues();
	}

	function parseAnimationSuffix(value:Int):String {
		if (value == CharacterCreatorState.spriteData.maxPressure + 2)
			return 'Overinflated';
		if (value == CharacterCreatorState.spriteData.maxPressure + 1)
			return 'Null';
		return value + '';
	}

	function getParticleOffset(key:String = 'origin'):FlxPoint {
		var huh:Array<Float> = (key == 'origin') ? CharacterCreatorState.spriteData.originPosition : (Reflect.getProperty(CharacterCreatorState.spriteData.particleOffsets, currentOffsetType)[currentPressure] ?? [0.0, 0.0]);
		return FlxPoint.get(huh[0], huh[1]);
	}

	function reloadSprite() {
		var graphic:FlxGraphic = Paths.image('ui/menus/utilities/silhouette');
		var path = UtilitiesBaseMenuState.loadedPath + '/sprites/${offsetsAnimation.get(currentOffsetType)}${parseAnimationSuffix(currentPressure)}/0.png';
		if (FileSystem.exists(path)) {
			graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
		}
		sprite.loadGraphic(graphic);
	}

	override function update(elapsed:Float) {
		var stepSize:Int = 1;
		if (FlxG.keys.anyPressed([SHIFT, CONTROL])) stepSize = 10;
		if (Controls.justPressed('left')) {
			moveMarker(-1 * stepSize, 0);
		} else if (Controls.justPressed('right')) {
			moveMarker(1 * stepSize, 0);
		}
		if (Controls.justPressed('up')) {
			moveMarker(0, -1 * stepSize);
		} else if (Controls.justPressed('down')) {
			moveMarker(0, 1 * stepSize);
		}
		super.update(elapsed);
	}

	function moveMarker(deltaX:Int = 0, deltaY:Int = 0) {
		if (currentOffsetType == 'origin') {
			originMarker.x = Std.int(originMarker.x + deltaX);
			originMarker.y = Std.int(originMarker.y + deltaY);
		} else {
			offsetMarker.x = Std.int(offsetMarker.x + deltaX);
			offsetMarker.y = Std.int(offsetMarker.y + deltaY);
		}
		updateValues();
	}

	function updateValues() {
		origin.x = originMarker.x - sprite.x;
		origin.y = originMarker.y - sprite.y;
		CharacterCreatorState.spriteData.originPosition = [origin.x, origin.y];
		offset.x = offsetMarker.x - originMarker.x;
		offset.y = offsetMarker.y - originMarker.y;
		offsetTxt.text = Language.getPhrase('offsetEditor.offsetType.origin') + '\n[${origin.x}, ${origin.y}]';
		if (currentOffsetType != 'origin') {
			Reflect.getProperty(CharacterCreatorState.spriteData.particleOffsets, currentOffsetType)[currentPressure] = [offset.x, offset.y];
			offsetTxt.text = Language.getPhrase('offsetEditor.offsetType.' + currentOffsetType) + '\n[${offset.x}, ${offset.y}]\n' + offsetTxt.text;
		}
		offsetTxt.y = FlxG.height - offsetTxt.height - 32;
	}
}
