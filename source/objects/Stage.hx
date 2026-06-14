package objects;

import flixel.FlxBasic;
import states.PlayState;
import backend.typedefs.StageData;
import tjson.TJSON as Json;
import backend.typedefs.StageObjectData;
import backend.typedefs.AnimationData;
import backend.CharacterManager;

class Stage extends FlxBasic {
	private var game(get, never):PlayState;
	public var data:StageData;
	public var objects:Map<String, StageObject> = new Map<String, StageObject>();

	public function new(id:String = 'reloaded') {
		data = cast Json.parse(Paths.getTextFromFile('data/stages/$id.json'));
		data.id = id;
		if (data.music == null)
			data.music = 'stages/${data.id}';
		var musicPath = Paths.getMusicPath(data.music);
		if (!Paths.fileExists(musicPath)) {
			trace('Specialized music path for stage ($musicPath) does not exist. Using default path');
			data.music = 'stages/default';
		}
		super();
	}

	public function load() {
		var backgroundObjects:Array<StageObjectData> = data.backgroundObjects;
		var tableObjects:Array<StageObjectData> = data.tableObjects;
		var foregroundObjects:Array<StageObjectData> = data.foregroundObjects;
		for (object in backgroundObjects) {
			if (Preferences.data.decreaseDetail && object.hideInDecreaseDetail == true) continue;
			var obj:StageObject = loadObject(object, data.id);
			addBehindCharacters(object.id, obj);
		}
		trace('Loaded background objects');
		for (object in tableObjects) {
			if (Preferences.data.decreaseDetail && object.hideInDecreaseDetail == true) continue;
			var obj:StageObject = loadObject(object, data.id);
			addBehindGun(object.id, obj);
		}
		trace('Loaded table objects');
		for (object in foregroundObjects) {
			if (Preferences.data.decreaseDetail && object.hideInDecreaseDetail == true) continue;
			var obj:StageObject = loadObject(object, data.id);
			addObject(object.id, obj);
		}
		trace('Loaded foreground objects');
	}

	public static function parsePosition(object:FlxSprite, pos:Array<String>):Array<Float> {
		var x:Float = 0;
		var y:Float = 0;
		if (pos[0].startsWith('c')) {
			var subtract:Bool = false;
			var arr = pos[0].split('+');
			if (arr.length <= 1) {
				arr = arr[0].split('-');
				subtract = true;
			}
			if (arr.length <= 1) {
				arr.push('0');
				subtract = false;
			}
			x = (FlxG.width - object.width) / 2 + Std.parseFloat(arr[1].trim()) * (subtract ? -1 : 1);
		} else {
			x = Std.parseFloat(pos[0]);
		}
		if (pos[1].startsWith('c')) {
			var subtract:Bool = false;
			var arr = pos[1].split('+');
			if (arr.length <= 1) {
				arr = arr[0].split('-');
				subtract = true;
			}
			if (arr.length <= 1) {
				arr.push('0');
				subtract = false;
			}
			y = (FlxG.height - object.height) / 2 + Std.parseFloat(arr[1].trim()) * (subtract ? -1 : 1);
		} else {
			y = Std.parseFloat(pos[1]);
		}
		return [x, y];
	}

	public static function loadObject(objectData:StageObjectData, stageID:String = 'classic'):StageObject {
		var object:StageObject = new StageObject();
		if (objectData.walkStep != null)
			object.walkStep = objectData.walkStep;
		if (objectData.walkMovement != null)
			object.walkMovement = objectData.walkMovement;
		object.randomAnimOnRespawn = !(!objectData.randomAnimOnRespawn);
		if (objectData.respawnTime != null)
			object.respawnTime = objectData.respawnTime;
		if (objectData.animations != null) {
			object.frames = Paths.sparrowAtlas('game/stages/$stageID/' + objectData.graphic);
			var animations:Array<AnimationData> = cast objectData.animations;
			for (animData in animations) {
				object.animation.addByPrefix(animData.name, animData.prefix, animData.fps);
			}
			if (objectData.randomAnim == true)
				object.animation.play(FlxG.random.getObject(object.animation.getNameList()), true);
			else
				object.animation.play(animations[0].name, true);
		} else {
			object.loadGraphic(Paths.image('game/stages/$stageID/' + objectData.graphic));
		}
		if (objectData.scrollFactor != null && objectData.scrollFactor.length == 2)
			object.scrollFactor.set(objectData.scrollFactor[0], objectData.scrollFactor[1]);
		if (objectData.hideCharacter != null)
			object.visible = !CharacterManager.selectedCharacterList.contains(objectData.hideCharacter);
		if (objectData.showCharacter != null)
			object.visible = CharacterManager.selectedCharacterList.contains(objectData.showCharacter);
		if (objectData.scale != null) {
			if (objectData.scale.length == 2)
				object.scale.set(objectData.scale[0], objectData.scale[1]); else if (objectData.scale.length == 1)
				object.scale.set(objectData.scale[0], objectData.scale[0]);
		}
		if (objectData.updateHitbox == true)
			object.updateHitbox();
		if (objectData.color != null)
			object.color = FlxColor.fromString(objectData.color);
		if (objectData.alpha != null)
			object.alpha = objectData.alpha;
		if (!Preferences.data.decreaseDetail) {
			if (objectData.blend != null)
				object.blend = objectData.blend.toLowerCase();
		}
		if (objectData.flipX != null)
			object.flipX = objectData.flipX;
		if (objectData.flipY != null)
			object.flipY = objectData.flipY;
		if (objectData.angle != null)
			object.angle = objectData.angle;
		if (objectData.velocity != null && objectData.velocity.length == 2)
			object.velocity.set(objectData.velocity[0], objectData.velocity[1]);
		if (objectData.angularVelocity != null)
			object.angularVelocity = objectData.angularVelocity;
		object.antialiasing = (objectData.antialiasing == true) && !Preferences.data.enableForcedAliasing;
		var pos = parsePosition(object, objectData.position);
		object.x = pos[0];
		object.y = pos[1];
		object.originalPosition.set(pos[0], pos[1]);

		trace('Stage object loaded: $objectData');
		return object;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	public function addObject(tag:String, object:StageObject) {
		objects.set(tag, object);
		return game.add(object);
	}

	public function addBehindGun(tag:String, object:StageObject) {
		objects.set(tag, object);
		return game.members.insert(game.members.indexOf(game.pumpGun), object);
	}

	public function addBehindCharacters(tag:String, object:StageObject) {
		objects.set(tag, object);
		return game.members.insert(game.members.indexOf(game.characterGroup), object);
	}

	private function get_game() {
		return cast FlxG.state;
	}
}