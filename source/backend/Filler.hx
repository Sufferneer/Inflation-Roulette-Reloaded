package backend;

import tjson.TJSON as Json;
import backend.typedefs.FillerSoundData;
import backend.typedefs.FillerData;
import objects.particles.Puff;
import objects.particles.Liquid;

class Filler {
	public var id:String = 'nameless';
	public var particleType:Class<FlxSprite> = Puff;
	public var particleColor:FlxColor = 0xFFFFFFFF;

	public var displayColor:FlxColor = 0xFFFFFFFF;
	public var gasColor:FlxColor = 0xFFFFFFFF;
	public var liquidColor:FlxColor = 0xFFFFFFFF;

	public var tintColor:Null<FlxColor>;
	public var destabilizationFactor:Array<Float> = [0, 0, 0];

	public var gurgles:FillerSoundData;
	public var creaks:FillerSoundData;
	public var belches:FillerSoundData;
	public var leaks:FillerSoundData;
	public var bursts:FillerSoundData;

	public var gravityMultiplier:Float = 1;
	public var stumbleForce:Float = 0;
	public var navelLeaks:Bool = false;
	public var npcOnPop:String = '';
	public var npcCountOnPop:Array<Int> = [0, 0];

	public function new(id:String) {
		this.id = id;
		var rawData:FillerData = cast Json.parse(Paths.getTextFromFile('data/fillers/$id.json'));
		if (rawData.displayColor != null)
			this.displayColor = FlxColor.fromString(rawData.displayColor);
		if (rawData.gasColor != null)
			this.gasColor = FlxColor.fromString(rawData.gasColor);
		if (rawData.liquidColor != null)
			this.liquidColor = FlxColor.fromString(rawData.liquidColor);
		if (rawData.particleType != null) {
			switch (rawData.particleType) {
				case 'gas':
					particleType = Puff;
					particleColor = gasColor;
				case 'liquid':
					particleType = Liquid;
					particleColor = liquidColor;
			}
		}

		if (rawData.tintColor != null)
			this.tintColor = FlxColor.fromString(rawData.tintColor);
		if (rawData.destabilizationFactor != null)
			this.destabilizationFactor = rawData.destabilizationFactor;

		if (rawData.gurgles != null) {
			this.gurgles = cast rawData.gurgles;
			this.gurgles.samples = determineSamples(this.gurgles.samples);
		}
		if (rawData.creaks != null) {
			this.creaks = cast rawData.creaks;
			this.creaks.samples = determineSamples(this.creaks.samples);
		}
		if (rawData.belches != null) {
			this.belches = cast rawData.belches;
			this.belches.samples = determineSamples(this.belches.samples);
		}
		if (rawData.leaks != null) {
			this.leaks = cast rawData.leaks;
			this.leaks.samples = determineSamples(this.leaks.samples);
		}
		if (rawData.bursts != null) {
			this.bursts = cast rawData.bursts;
			this.bursts.samples = determineSamples(this.bursts.samples);
		}

		if (rawData.gravityMultiplier != null)
			this.gravityMultiplier = rawData.gravityMultiplier;
		if (rawData.stumbleForce != null)
			this.stumbleForce = rawData.stumbleForce;
		if (rawData.navelLeaks != null)
			this.navelLeaks = rawData.navelLeaks;
		if (rawData.npcOnPop != null)
			this.npcOnPop = rawData.npcOnPop;
		if (rawData.npcCountOnPop != null)
			this.npcCountOnPop = rawData.npcCountOnPop;
	}

	public function determineSamples(samples:Int):Int {
		if (!Preferences.data.decreaseSounds) return samples;
		if (samples <= 4) return samples;
		return Std.int(FlxMath.bound(samples / 2, 1, 10));
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
