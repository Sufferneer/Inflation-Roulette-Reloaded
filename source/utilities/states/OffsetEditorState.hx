package utilities.states;

import ui.objects.SuffMarker;
import ui.objects.SuffSlider;
import objects.Character;
import ui.objects.SuffIconButton;
import openfl.utils.ByteArray;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.display.BitmapData.BitmapData.fromFile;
import backend.FileDialogHandler;
import backend.typedefs.CharacterOffsetsData;
import utilities.substates.ChoicePrompt;
using StringTools;

class OffsetEditorState extends UtilitiesBaseMenuState {
	var sprite:Character;
	var markers:Map<String, SuffMarker> = [];
	var offsetTxt:FlxText;

	var offsetList = ['origin', 'cameraOffset', 'poppedCameraOffset', 'particle'];
	var particleOffsetButtons:FlxTypedContainer<SuffButton> = new FlxTypedContainer<SuffButton>();
	var particleOffsetList = ['overhead', 'mouth', 'navel', 'gunShoot', 'gunSkill'];
	var offsetsAnimation:Map<String, String> = [
		'overhead' => 'idle',
		'mouth' => 'belch',
		'navel' => 'idle',
		'gunShoot' => 'shootBlank',
		'gunSkill' => 'skill',
	];
	var currentOffsetType:String = 'origin';
	var currentParticleOffsetType:String = 'overhead';
	var currentPressure:Int = 0;

	var camFollow:FlxObject;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	override public function create() {
		Window.setTitle(Language.getPhrase('utilitiesMenu.windowDisplay'), Language.getPhrase('utilitiesMenu.offsetEditor'));

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.camera.follow(camFollow);
		FlxG.camera.followLerp = 0.25;

		super.create();
		remove(exitButton);

		var lePath = UtilitiesBaseMenuState.loadedPath.split('/');
		var charId = lePath[lePath.length - 1];
		trace(charId);
		sprite = new Character(charId, FlxG.width / 2);
		sprite.y = (FlxG.height - sprite.height) / 2 + sprite.offset.y;
		add(sprite);

		var leftBorder:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2 - sprite.width / 2), FlxG.height, 0xFF000000);
		leftBorder.alpha = 0.5;
		leftBorder.camera = camHUD;

		var rightBorder:FlxSprite = new FlxSprite(leftBorder.width + sprite.width, 0).makeGraphic(Std.int(FlxG.width / 2 - sprite.width / 2), FlxG.height, 0xFF000000);
		rightBorder.alpha = 0.5;
		rightBorder.camera = camHUD;

		var upBorder:FlxSprite = new FlxSprite(leftBorder.width, 0).makeGraphic(Std.int(sprite.width), Std.int(FlxG.height / 2 - sprite.height / 2), 0xFF000000);
		upBorder.alpha = 0.5;
		upBorder.camera = camHUD;

		var downBorder:FlxSprite = new FlxSprite(leftBorder.width, upBorder.height + sprite.height).makeGraphic(Std.int(sprite.width), Std.int(FlxG.height / 2 - sprite.height / 2), 0xFF000000);
		downBorder.alpha = 0.5;
		downBorder.camera = camHUD;

		var marker = new SuffMarker(sprite.x, sprite.y, 0xFFFFFFFF);
		add(marker);
		markers.set('origin', marker);

		var marker = new SuffMarker(sprite.x + sprite.cameraOffset[0], sprite.y + sprite.cameraOffset[1], 0xFF00FFFF);
		add(marker);
		markers.set('cameraOffset', marker);

		var marker = new SuffMarker(sprite.x + sprite.poppedCameraOffset[0], sprite.y + sprite.poppedCameraOffset[1], 0xFFFF00FF);
		add(marker);
		markers.set('poppedCameraOffset', marker);

		var what = getParticleOffset(currentParticleOffsetType);
		var marker = new SuffMarker(sprite.x + what.x, sprite.y + what.y, 0xFFFFFF00);
		add(marker);
		markers.set('particle', marker);

		add(sprite);
		add(leftBorder);
		add(rightBorder);
		add(upBorder);
		add(downBorder);
		add(particleOffsetButtons);

		var actualExitButton:SuffIconButton = new SuffIconButton(10, 10, 'buttons/exit', 2);
		actualExitButton.x = FlxG.width - actualExitButton.width - 10;
		actualExitButton.y = FlxG.height - actualExitButton.height - 10;
		actualExitButton.camera = camHUD;
		actualExitButton.onClick = function() {
			leaveMenu();
		}
		add(actualExitButton);

		var saveButton = new SuffIconButton(exitButton.x - exitButton.width - 10, exitButton.y, 'buttons/save', 2);
		saveButton.onClick = function() {
			var fileDialog = new FileDialogHandler();
			var offsetData:CharacterOffsetsData = {
				originPosition: sprite.originPosition,
				poppedCameraOffset: sprite.poppedCameraOffset,
				cameraOffset: sprite.cameraOffset,
				particleOffsets: {
					overhead: sprite.particleOffsets.get('overhead'),
					mouth: sprite.particleOffsets.get('mouth'),
					navel: sprite.particleOffsets.get('navel'),
					gunShoot: sprite.particleOffsets.get('gunShoot'),
					gunSkill: sprite.particleOffsets.get('gunSkill')
				}
			};
			fileDialog.save('offsets.json', haxe.Json.stringify(offsetData, '\t'));
		}
		add(saveButton);

		for (num => offset in particleOffsetList) {
			var button = new SuffButton(rightBorder.x + 32, rightBorder.y + 32 + 72 * num, Language.getPhrase('offsetEditor.particleType.' + offset), rightBorder.width - 64, 64);
			button.onClick = function() {
				currentParticleOffsetType = offset;
				reloadSprite();
				var what = getParticleOffset(currentParticleOffsetType);
				getMarker('particle').setPosition(sprite.x + what.x, sprite.y + what.y);
				updateValues();
			}
			button.camera = camHUD;
			particleOffsetButtons.add(button);
		}

		updateMarkers();

		var helpTitle:FlxText = new FlxText(32, 32, leftBorder.width - 64, Language.getPhrase('offsetEditor.title'), 32);
		helpTitle.camera = camHUD;
		add(helpTitle);
		var helpDesc:FlxText = new FlxText(32, helpTitle.y + helpTitle.height, leftBorder.width - 40, Language.getPhrase('offsetEditor.description'), 16);
		helpDesc.camera = camHUD;
		add(helpDesc);
		var pressureSlider = new SuffSlider(helpDesc.x, helpDesc.y + helpDesc.height, function(val:Float) {
			currentPressure = Std.int(val);
			reloadSprite();
			var what = getParticleOffset(currentParticleOffsetType);
			getMarker('particle').setPosition(sprite.x + what.x, sprite.y + what.y);
			updateValues();
		}, 0, sprite.maxPressure + 2, 1, function(val:Float) {
			return Language.getPhrase("stats.pressure." + parseAnimationSuffix(Std.int(val)), [], Std.int(val) + '');
		});
		pressureSlider.camera = camHUD;
		add(pressureSlider);

		for (num => offset in offsetList) {
			var button = new SuffButton(helpTitle.x, pressureSlider.y + pressureSlider.height + 72 * num, Language.getPhrase('offsetEditor.offsetType.' + offset), leftBorder.width - 64, 64);
			button.onClick = function() {
				currentOffsetType = offset;
				updateMarkers();
				updateValues();
			}
			button.camera = camHUD;
			add(button);
		}

		offsetTxt = new FlxText(32, 32, leftBorder.width - 64, '[0, 0]', 32);
		offsetTxt.y = FlxG.height - offsetTxt.height - 32;
		offsetTxt.camera = camHUD;
		add(offsetTxt);

		updateValues();
	}

	public override function leaveMenu() {
		openSubState(new ChoicePrompt('offsetEditor.exit.prompt', function() {
			SuffState.switchState(new UtilitiesMainMenuState());
		}, function() {

		}));
	}

	function parseAnimationSuffix(value:Int):String {
		if (value == sprite.maxPressure + 2)
			return 'Overinflated';
		if (value == sprite.maxPressure + 1)
			return 'Null';
		return value + '';
	}

	function getParticleOffset(key:String = 'overhead'):FlxPoint {
		var huh:Array<Float> = sprite.particleOffsets.get(key)[currentPressure] ?? [0.0, 0.0];
		return FlxPoint.get(huh[0], huh[1]);
	}

	function reloadSprite() {
		var animName = offsetsAnimation.get(currentParticleOffsetType) + parseAnimationSuffix(currentPressure);
		if (!sprite.animation.exists(animName))
			animName = 'idle' + parseAnimationSuffix(currentPressure);
		sprite.playAnim(animName, false, true);
		sprite.animation.pause();
	}

	function getMarker(type:String) {
		return markers.get(type);
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
		getMarker(currentOffsetType).x = Std.int(getMarker(currentOffsetType).x + deltaX);
		getMarker(currentOffsetType).y = Std.int(getMarker(currentOffsetType).y + deltaY);
		updateValues();
	}

	function updateMarkers() {
		for (id => marker in markers) {
			if (id == currentOffsetType)
				marker.alpha = 1;
			else if (id == 'particle')
				marker.alpha = 0.2;
			else
				marker.alpha = 0.2;
		}
		particleOffsetButtons.forEach(function (button) button.disabled = (currentOffsetType != 'particle'));
	}

	function updateValues() {
		var offset:FlxPoint = FlxPoint.get(
			getMarker(currentOffsetType).x - sprite.x,
			getMarker(currentOffsetType).y - sprite.y
		);
		if (currentOffsetType == 'cameraOffset' || currentOffsetType == 'poppedCameraOffset') {
			camFollow.setPosition(getMarker(currentOffsetType).x, getMarker(currentOffsetType).y);
		} else {
			camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		}
		switch (currentOffsetType) {
			case 'origin':
				offset.set(
					getMarker(currentOffsetType).x - (sprite.x - sprite.offset.x),
					getMarker(currentOffsetType).y - (sprite.y - sprite.offset.y)
				);
				sprite.originPosition = [offset.x, offset.y];
				sprite.offset.set(offset.x, offset.y);
			case 'cameraOffset':
				sprite.cameraOffset = [offset.x, offset.y];
			case 'poppedCameraOffset':
				sprite.poppedCameraOffset = [offset.x, offset.y];
			case 'particle':
				sprite.particleOffsets.get(currentParticleOffsetType)[currentPressure] = [offset.x, offset.y];
		}
		offsetTxt.text = '[${offset.x}, ${offset.y}]';
		if (currentOffsetType != 'particle') {
			offsetTxt.text = Language.getPhrase('offsetEditor.offsetType.' + currentOffsetType) + '\n' +
			offsetTxt.text;
		} else {
			offsetTxt.text = Language.getPhrase('offsetEditor.offsetType.' + currentOffsetType) + '\n' +
			Language.getPhrase('offsetEditor.particleType.' + currentParticleOffsetType) + '\n' +
			offsetTxt.text;
		}
		offsetTxt.y = FlxG.height - offsetTxt.height - 32;
	}
}
