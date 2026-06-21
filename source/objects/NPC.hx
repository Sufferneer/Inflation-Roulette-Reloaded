package objects;

import backend.Gameplay;
import backend.typedefs.NPCData;

import tjson.TJSON as Json;
import backend.typedefs.AnimationData;
import states.PlayState;

enum NPCAction {
	IDLE;
	WALK;
	TAUNT;
}

class NPC extends FlxSprite {
	// Metadata //
	public var id:String = 'unnamed';

	public var copyCharacterId:Bool = false;
	public var mergeable:Bool = false;
	public var mergedNpc:String = '';
	public var walkSpeed:Float = 640;
	public var idleDuration:Array<Float> = [3, 6];
	public var tauntChance:Float = 0.2;
	public var sizeMultiplier:Array<Float> = [1, 1];
	public var originPosition:Array<Float> = [80, 160];
	public var hitboxSize:Array<Float> = [80, 80];

	public var currentCharacterId:String = 'universal';
	public var movement:FlxPoint = FlxPoint.get(0, 0);
	public var targetX:Null<Float> = null;
	public var currentAction:NPCAction = IDLE;
	public var moveRange:Array<Float> = [0, 1280];

	public var transmutateValue:Int = 1;
	public var transmutateThreshold:Int = -1;
	public var targetScale:Float = 0;
	public var scaleLerped:Float = 0;

	public function new(npcId:String, x:Float = 0, y:Float = 0, characterId:String = null) {
		this.active = false;

		this.id = npcId;
		var rawJson:NPCData = cast Json.parse(Paths.getTextFromFile('data/npcs/' + id + '.json'));

		this.copyCharacterId = rawJson.copyCharacterId ?? false;
		this.currentCharacterId = (copyCharacterId && characterId != null) ? characterId : 'universal';
		if (Paths.sparrowAtlas('game/npcs/$npcId/' + currentCharacterId) == null)
			this.currentCharacterId = 'universal';
		this.mergeable = rawJson.mergeable ?? false;
		this.mergedNpc = rawJson.mergedNpc ?? '';
		this.walkSpeed = rawJson.walkSpeed ?? 640;
		this.idleDuration = rawJson.idleDuration ?? [3, 6];
		this.tauntChance = rawJson.tauntChance ?? 0.2;
		this.hitboxSize = rawJson.hitboxSize ?? [80, 80];
		this.sizeMultiplier = rawJson.sizeMultiplier ?? [1, 1];
		this.originPosition = rawJson.originPosition ?? [80, 160];

		this.moveRange = [
			PlayState?.instance?.stage?.data?.cameraBounds[0] + this.hitboxSize[0],
			PlayState?.instance?.stage?.data?.cameraBounds[0] + PlayState?.instance?.stage?.data?.cameraBounds[2] - this.hitboxSize[0]
		];

		super(x, y);
		this.frames = Paths.sparrowAtlas('game/npcs/$npcId/' + currentCharacterId);
		var animationArray:Array<AnimationData> = rawJson.animations ?? [];
		for (anim in animationArray) {
			var name = anim.name;
			var prefix = anim.prefix;
			var fps = anim.fps ?? 24;
			var indices = anim.indices ?? [];
			var looped = anim.loop ?? false;
			if (indices.length <= 0)
				this.animation.addByPrefix(name, prefix, fps, looped);
			else
				this.animation.addByIndices(name, prefix, indices, '', fps, looped);
		}
		this.animation.play('idle', true);
		this.offset.x = this.originPosition[0];
		this.offset.y = this.originPosition[1];
		this.origin.y = this.height - (this.height - this.originPosition[1]);
		this.targetScale = FlxG.random.float(sizeMultiplier[0], sizeMultiplier[1]);
		this.scaleLerped = this.targetScale / 4;

		this.acceleration.y = 4800;

		determineIdle();

		this.active = true;
	}

	public function getIdleDelay(multiplier:Float = 1)
		return FlxG.random.float(idleDuration[0], idleDuration[1]) * multiplier;

	public function taunt() {
		currentAction = TAUNT;
		var nameList:Array<String> = animation.getNameList();
		var tauntAnim:String = FlxG.random.getObject(nameList);
		while (tauntAnim == 'idle' || tauntAnim == 'walk')
			tauntAnim = FlxG.random.getObject(nameList);
		animation.play(tauntAnim, true);
	}

	public function getCurAnimLength() {
		return (animation?.curAnim?.numFrames - 1) / animation?.curAnim?.frameRate ?? 0;
	}

	public function walk() {
		currentAction = WALK;
		var tempTargetX:Float = 0;
		for (i in 0...10) {
			tempTargetX = FlxG.random.float(320, 640) * FlxG.random.int(-1, 1, [0]);
			if (FlxMath.inBounds(this.x + tempTargetX, moveRange[0], moveRange[1]))
				break;
		}
		this.targetX = FlxMath.bound(this.x + tempTargetX, moveRange[0], moveRange[1]);
		this.movement.x = FlxMath.signOf(this.targetX - this.x) * walkSpeed;
		this.animation.play('walk', true);
		this.flipX = (this.movement.x < 0);
	}

	public function determineIdle() {
		currentAction = IDLE;
		this.animation.play('idle', true);
		new FlxTimer().start(getIdleDelay(), function(_) {
			if (FlxG.random.bool(tauntChance * 100)) {
				taunt();
				new FlxTimer().start(getCurAnimLength(), function(_) {
					determineIdle();
				});
			} else {
				walk();
			}
		});
	}

	public override function destroy() {
		FlxTween.cancelTweensOf(this);
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
			tmr.cancel();
			tmr.destroy();
		});
		super.destroy();
	}

	public static function onCollide(target:NPC, collider:NPC) {
		if ((target.id != collider.id) ||
			!target.active || !collider.active ||
			!target.mergeable || !collider.mergeable ||
			target?.acceleration.y != 0 || collider?.acceleration.y != 0 ||
			(target.currentCharacterId != collider.currentCharacterId) ||
			target.transmutateThreshold == -1 || collider.transmutateThreshold == -1)
			return;
		var transmutate = target.transmutateValue + collider.transmutateValue;
		var completeTransmutation = transmutate >= target.transmutateThreshold;
		var npcId:String = completeTransmutation ? target.mergedNpc : target.id;
		var newNpc:NPC = new NPC(npcId, (target.x + collider.x) / 2, (target.y + collider.y) / 2, target.currentCharacterId);
		newNpc.transmutateThreshold = target.transmutateThreshold;
		newNpc.transmutateValue = transmutate;
		if (!completeTransmutation) {
			newNpc.scaleLerped = (target.scale.x + collider.scale.x) / 4;
			newNpc.targetScale = (target.scale.x + collider.scale.x) / 2 + 0.2;
		}
		target.active = false;
		PlayState.instance.npcGroup.remove(target);
		collider.active = false;
		PlayState.instance.npcGroup.remove(collider);
		PlayState.instance.npcGroup.add(newNpc);
	}

	public static function isColliding(target:NPC, collider:NPC) {
		var targetHitbox = FlxRect.get(target.x - target.hitboxSize[0] / 2, target.y - target.hitboxSize[1], target.hitboxSize[0], target.hitboxSize[1]);
		var colliderHitbox = FlxRect.get(collider.x - collider.hitboxSize[0] / 2, collider.y - collider.hitboxSize[1], collider.hitboxSize[0], collider.hitboxSize[1]);
		return (targetHitbox.overlaps(colliderHitbox));
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (this == null || !this.exists || !this.active)
			return;

		FlxG.overlap(this, PlayState.instance.npcGroup, onCollide, isColliding);

		scaleLerped = FlxMath.lerp(scaleLerped, targetScale, elapsed * 6);
		this.scale.set(scaleLerped, scaleLerped);

		if (targetX != null) {
			if ((this.movement.x > 0 && this.x >= targetX) || this.movement.x < 0 && this.x <= targetX) {
				targetX = null;
				this.movement.x = 0;
				determineIdle();
			}
		}
		if (this.currentAction == WALK) {
			this.velocity.x = this.movement.x;
			this.velocity.y = this.movement.y;
		}
		if (this.y >= PlayState.instance.stage.data.characterY) {
			this.acceleration.y = 0;
			this.y = PlayState.instance.stage.data.characterY;
			this.velocity.x *= (1 - elapsed * 10);
		}
	}
}
