package utilities.states;

import ui.addons.SuffUIButton;
import tjson.TJSON as Json;
import utilities.substates.ChoicePrompt;
import backend.typedefs.StageData;
import backend.typedefs.StageObjectData;
import objects.Stage;
import utilities.objects.CharacterDummy;
import ui.addons.SuffUIWidget;
import flixel.util.FlxCollision;
import utilities.enums.StageEditorObjectType;
import openfl.Lib;
#if _ALLOW_UTILITIES
import backend.FileDialogHandler;
#end
import openfl.display.PNGEncoderOptions;
import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import backend.CharacterManager;

class StagePreviewerState extends UtilitiesBaseMenuState {
	public static final version:String = '2.0.0';

	public static var stageData:StageData;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	var camFollow:FlxObject;

	var characterGroup:FlxTypedContainer<CharacterDummy>;
	var objectsOrder:Array<String> = [];
	var objects:Map<String, FlxSprite> = [];
	var pumpGun:FlxSprite;

	var cameraTxt:FlxText;

	function getPath() {
		return UtilitiesBaseMenuState.loadedPath;
	}

	override function create() {
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		super.create();
		Window.setTitle(Language.getPhrase('utilitiesMenu.windowDisplay'), Language.getPhrase('utilitiesMenu.stagePreviewer'));

		escapeToLeave = false;

		stageData = cast Json.parse(File.getContent(getPath()));

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2, 1, 1);
		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.setScrollBoundsRect(stageData.cameraBounds[0], stageData.cameraBounds[1], stageData.cameraBounds[2], stageData.cameraBounds[3]);

		remove(bg);

		characterGroup = new FlxTypedContainer<CharacterDummy>();
		for (i in 0...4) {
			var dummy:CharacterDummy = new CharacterDummy();
			characterGroup.add(dummy);
		}
		add(characterGroup);

		pumpGun = new FlxSprite().loadGraphic(Paths.image('game/pumpGun'));
		add(pumpGun);

		cameraTxt = new FlxText(16, 16, '[0, 0]\n1.0', 32);
		cameraTxt.camera = camHUD;
		cameraTxt.y = FlxG.height - cameraTxt.height - 16;

		reloadBG();
		remove(exitButton);
		generateStageUI();
		generateObjectListUI();
		add(cameraTxt);
		updateCameraTxt();
	}

	function moveCamera(deltaX:Float = 0, deltaY:Float = 0) {
		camFollow.x = Math.round(FlxMath.bound(camFollow.x + deltaX, stageData.cameraBounds[0] + FlxG.width / 2, stageData.cameraBounds[0] + stageData.cameraBounds[2] - FlxG.width / 2));
		camFollow.y = Math.round(FlxMath.bound(camFollow.y + deltaY, stageData.cameraBounds[1] + FlxG.height / 2, stageData.cameraBounds[1] + stageData.cameraBounds[3] - FlxG.height / 2));
		updateCameraTxt();
	}

	function zoomCamera(delta:Float = 0) {
		FlxG.camera.zoom = FlxG.camera.zoom + delta;
		updateCameraTxt();
	}

	function updateCameraTxt() {
		cameraTxt.text = '[${Math.round(camFollow.x)}, ${Math.round(camFollow.y)}]\n${FlxMath.roundDecimal(FlxG.camera.zoom, 2)}';
	}

	public function addObject(tag:String, object:FlxSprite) {
		objectsOrder.unshift(tag);
		objects.set(tag, object);
		object.active = true;
		return add(object);
	}

	public function addBehindGun(tag:String, object:FlxSprite) {
		objectsOrder.unshift(tag);
		objects.set(tag, object);
		object.active = true;
		return members.insert(members.indexOf(pumpGun), object);
	}

	public function addBehindCharacters(tag:String, object:FlxSprite) {
		objectsOrder.unshift(tag);
		objects.set(tag, object);
		object.active = true;
		return members.insert(members.indexOf(characterGroup), object);
	}

	function reloadBG() {
		var lePath = getPath();
		stageData = cast Json.parse(File.getContent(lePath));
		stageData.id = haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(lePath));
		trace(stageData.id);
		for (obj in objects) {
			if (obj != pumpGun)
				members.remove(obj);
		}
		objectsOrder.resize(0);
		var backgroundObjects:Array<StageObjectData> = stageData.backgroundObjects;
		var tableObjects:Array<StageObjectData> = stageData.tableObjects;
		var foregroundObjects:Array<StageObjectData> = stageData.foregroundObjects;
		for (object in backgroundObjects) {
			var obj:FlxSprite = Stage.loadObject(object, stageData.id);
			addBehindCharacters(object.id, obj);
		}
		for (i in 1...5) {
			var tag = 'character' + i;
			objectsOrder.unshift(tag);
			objects.set(tag, characterGroup.members[i - 1]);
		}
		for (object in tableObjects) {
			var obj:FlxSprite = Stage.loadObject(object, stageData.id);
			addBehindGun(object.id, obj);
		}
		objectsOrder.unshift('pumpGun');
		objects.set('pumpGun', pumpGun);
		for (object in foregroundObjects) {
			var obj:FlxSprite = Stage.loadObject(object, stageData.id);
			addObject(object.id, obj);
		}
		for (num => char in characterGroup) {
			char.x = Std.int(FlxMath.lerp(FlxG.width / 2 + stageData.characterX[0], FlxG.width / 2 + stageData.characterX[1], num / 3));
			char.y = stageData.characterY;
		}
		pumpGun.x = characterGroup.members[0].x - pumpGun.width / 2;
		pumpGun.y = stageData.gunY;
		pumpGun.scrollFactor.set(stageData.gunScrollFactor[0], stageData.gunScrollFactor[1]);

		camFollow.x = Std.int(FlxG.width / 2);
		camFollow.y = Std.int(FlxG.height / 2);
		FlxG.camera.zoom = 1;

		moveCamera();
		zoomCamera();

		trace(objectsOrder);
	}

	var stageUI:SuffUIWidget;

	function generateStageUI() {
		stageUI = new SuffUIWidget(970, 10, 250, 300);
		stageUI.setLabelText(Language.getPhrase('stagePreviewer.stage'));
		stageUI.camera = camHUD;
		stageUI.draggable = false;
		stageUI.x = FlxG.width - stageUI.width - 10;
		add(stageUI);

		var text:FlxText = new FlxText(20, 40, stageUI.width - 40, Language.getPhrase('stagePreviewer.stage.description'), 16);
		stageUI.addObject(text);

		var exitButton = new SuffUIButton(Language.getPhrase('stagePreviewer.exit'), function () {
			leaveMenu();
		});
		exitButton.resize(stageUI.width - 40, 32);
		exitButton.color = 0xFF2020;
		exitButton.label.color = 0xFFFFFF;
		exitButton.x = 20;
		exitButton.y = stageUI.height - exitButton.height - 20;

		var screenshotButton = new SuffUIButton(Language.getPhrase('stagePreviewer.screenshot'), function () {
			screenShot();
		});
		screenshotButton.resize(exitButton.width, exitButton.height);
		screenshotButton.x = 20;
		screenshotButton.y = exitButton.y - screenshotButton.height - 5;

		var reloadButton = new SuffUIButton(Language.getPhrase('stagePreviewer.reload'), function () {
			reloadBG();
		});
		reloadButton.resize(exitButton.width, exitButton.height);
		reloadButton.x = 20;
		reloadButton.y = screenshotButton.y - screenshotButton.height - 5;

		stageUI.addObject(exitButton);
		stageUI.addObject(reloadButton);
		stageUI.addObject(screenshotButton);
	}

	function screenShot() {
		camFollow.x = Std.int(FlxG.width / 2);
		camFollow.y = Std.int(FlxG.height / 2);
		FlxG.camera.zoom = 0.8;

		inScreenshotMode = true;

		stageUI.visible = objectListUI.visible = cameraTxt.visible = characterGroup.visible = pumpGun.visible = false;
		Main.debugText.alpha = 0;
		CursorHandler.cursorVisible = false;
	}

	var inScreenshotMode:Bool = false;

	var objectListUI:SuffUIWidget;

	function generateObjectListUI() {
		objectListUI = new SuffUIWidget(10, 10, 200, FlxG.height - 20);
		objectListUI.draggable = false;
		objectListUI.setLabelText(Language.getPhrase('stagePreviewer.objectList', ['N/A']));
		objectListUI.camera = camHUD;
		add(objectListUI);

		for (num => obj in objectsOrder) {
			var objButton:SuffUIButton = new SuffUIButton(20, 40 + 30 * num, obj, function() {
				selectObject(obj);
			});
			switch (obj) {
				case 'character1' | 'character2' | 'character3' | 'character4' | 'pumpGun':
					objButton.color = 0xFFFF00;
				default:
					objButton.color = 0xFFFFFF;
			}
			objButton.resize(objectListUI.width - 40, 25);
			objectListUI.addObject(objButton);
		}
	}
	var selectedObject:String;
	var moveRate:Float = 1;

	function exitScreenshotMode() {
		inScreenshotMode = false;
		Main.debugText.alpha = 0.5;
		CursorHandler.cursorVisible = true;
		moveCamera();
		zoomCamera();
		stageUI.visible = objectListUI.visible = cameraTxt.visible = characterGroup.visible = pumpGun.visible = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			if (selectedObject != null)
				selectedObject = null;
			else if (inScreenshotMode) {
				exitScreenshotMode();
			} else
				leaveMenu();
		}
		if (inScreenshotMode && FlxG.mouse.deltaScreenX >= 50 * (60 / FlxG.updateFramerate)) {
			exitScreenshotMode();
		}
		moveRate = FlxG.keys.pressed.SHIFT ? 5 : 1;
		if (FlxG.keys.pressed.LEFT) {
			moveCamera(-100 * elapsed * moveRate, 0);
		} else if (FlxG.keys.pressed.RIGHT) {
			moveCamera(100 * elapsed * moveRate, 0);
		}
		if (FlxG.keys.pressed.UP) {
			moveCamera(0, -100 * moveRate * elapsed);
		} else if (FlxG.keys.pressed.DOWN) {
			moveCamera(0, 100 * moveRate * elapsed);
		}
		if (FlxG.keys.pressed.Q) {
			zoomCamera(-0.2 * moveRate * elapsed);
		} else if (FlxG.keys.pressed.E) {
			zoomCamera(0.2 * moveRate * elapsed);
		}
	}

	function selectObject(tag:String) {
		selectedObject = tag;
		reloadObjectUI(selectedObject);
	}

	function evalObjectType(tag:String):StageEditorObjectType {
		if (tag.startsWith('character')) {
			return CHARACTER;
		} else if (tag == 'pumpGun') {
			return GUN;
		}
		return BG;
	}

	function reloadObjectUI(tag:String) {
		var leObj:FlxSprite = objects.get(tag);
		var type:StageEditorObjectType = evalObjectType(tag);
		camFollow.x = leObj.x + leObj.width / 2 * (type != CHARACTER ? 1 : 0);
		camFollow.y = leObj.y + (type != CHARACTER ? leObj.height / 2 : -leObj.height / 2);
		updateCameraTxt();
	}

	public override function leaveMenu() {
		openSubState(new ChoicePrompt('stagePreviewer.exit.prompt', function() {
			SuffState.switchState(new UtilitiesMainMenuState());
		}));
	}
}
