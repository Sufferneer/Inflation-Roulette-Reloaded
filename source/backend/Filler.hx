package backend;

import backend.typedefs.GamemodeData;
import tjson.TJSON as Json;
import backend.typedefs.FillerSoundData;
import backend.typedefs.FillerData;

class Filler {
	public var id:String = 'nameless';

	public var displayColor:FlxColor = 0xFFFFFFFF;
	public var gasColor:FlxColor = 0xFFFFFFFF;
	public var liquidColor:FlxColor = 0xFFFFFFFF;

	public var tintColor:FlxColor = 0xFFFFFFFF;
	public var decolorizeFactor:Array<Float> = [0, 0, 0];

	public var gurgles:FillerSoundData;
	public var creaks:FillerSoundData;
	public var belches:FillerSoundData;
	public var leaks:FillerSoundData;
	public var bursts:FillerSoundData;

	public var gravityMultiplier:Float = 1;
	public var stumbleForce:Float = 0;
	public var disablePoppingPhysics:Bool = false;
	public var navelLeaks:Bool = false;
	public var npcOnPop:String = '';


	public function new(id:String) {
		this.id = id;
		var rawData:FillerData = cast Json.parse(Paths.getTextFromFile('data/fillers/$id.json'));
		if (rawData.displayColor != null)
			this.displayColor = FlxColor.fromString(rawData.displayColor);
		if (rawData.gasColor != null)
			this.gasColor = FlxColor.fromString(rawData.gasColor);
		if (rawData.liquidColor != null)
			this.liquidColor = FlxColor.fromString(rawData.liquidColor);

		if (rawData.tintColor != null)
			this.tintColor = FlxColor.fromString(rawData.tintColor);
		if (rawData.decolorizeFactor != null)
			this.decolorizeFactor = rawData.decolorizeFactor;

		if (rawData.gurgles != null) {
			this.gurgles = cast rawData.gurgles;
			if (Preferences.data.decreaseDetail)
				this.gurgles.samples = Std.int(FlxMath.bound(this.gurgles.samples / 2, 1, 10));
		}
		if (rawData.creaks != null) {
			this.creaks = cast rawData.creaks;
			if (Preferences.data.decreaseDetail)
				this.creaks.samples = Std.int(FlxMath.bound(this.creaks.samples / 2, 1, 10));
		}
		if (rawData.belches != null) {
			this.belches = cast rawData.belches;
			if (Preferences.data.decreaseDetail)
				this.belches.samples = Std.int(FlxMath.bound(this.belches.samples / 2, 1, 10));
		}
		if (rawData.leaks != null) {
			this.leaks = cast rawData.leaks;
			if (Preferences.data.decreaseDetail)
				this.leaks.samples = Std.int(FlxMath.bound(this.leaks.samples / 2, 1, 10));
		}
		if (rawData.bursts != null) {
			this.bursts = cast rawData.bursts;
			if (Preferences.data.decreaseDetail)
				this.bursts.samples = Std.int(FlxMath.bound(this.bursts.samples / 2, 1, 10));
		}

		if (rawData.gravityMultiplier != null)
			this.gravityMultiplier = cast rawData.gravityMultiplier;
		if (rawData.stumbleForce != null)
			this.stumbleForce = cast rawData.stumbleForce;
		if (rawData.disablePoppingPhysics != null)
			this.disablePoppingPhysics = cast rawData.disablePoppingPhysics;
		if (rawData.navelLeaks != null)
			this.navelLeaks = cast rawData.navelLeaks;
		if (rawData.npcOnPop != null)
			this.npcOnPop = cast rawData.npcOnPop;
	}

	public function getGurgleSound() {
		return Paths.soundRandom('game/inflation/${gurgles.archetype}/gurgles/gurgle', 1, gurgles.samples);
	}

	public function getCreakSound() {
		return Paths.soundRandom('game/inflation/${creaks.archetype}/creaks/creak', 1, creaks.samples);
	}

	public function getBelchSound() {
		return Paths.soundRandom('game/inflation/${belches.archetype}/belches/belch', 1, belches.samples);
	}
	public function getLeakSound() {
		return Paths.soundRandom('game/inflation/${leaks.archetype}/leaks/leak', 1, leaks.samples);
	}

	public function getBurstSound() {
		return Paths.soundRandom('game/inflation/${bursts.archetype}/bursts/burst', 1, bursts.samples) ?? Paths.sound('game/inflation/gas/bursts/burst_1');
	}

	public function toString():String {
		return 'Filler(id: ${id})';
	}
}
