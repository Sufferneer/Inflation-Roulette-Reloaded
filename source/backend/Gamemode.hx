package backend;

import backend.typedefs.GamemodeData;
import tjson.TJSON as Json;

class Gamemode {
	public var id:String = 'nameless';
	// public var name:String = 'Nameless';
	// public var description:String = 'No description.';
	public var color:FlxColor = 0xFFA0A0C0;

	public var cylinderSize:Int = Constants.CYLINDER_CAPACITY;
	public var cylinderLiveCount:Int = Constants.LIVE_ROUND_COUNT;
	public var cylinderReloadOnNoLives:Bool = true;
	public var cylinderInitialDamage:Int = 1;
	public var cylinderDamageChangeOnLive:Int = 0;
	public var cylinderDamageChangeOnBlank:Int = 0;
	public var cylinderTrueRandomness:Bool = false;

	public var skillsExhaustible:Bool = false;
	public var skillsFixedPool:Array<String> = [];
	public var skillsRandomPool:Array<String> = [];
	public var skillsCostMultiplier:Float = 1;
	public var skillsReplenishCountOnLive:Int = 0;
	public var skillsReplenishCountOnBlank:Int = 0;

	public var scoreWinBonusMultiplier:Float = 1;
	public var scoreEdgingBonusMultiplierRange:Array<Float> = [0.5, 1.0];
	public var scoreEdgingBonusMultiplier:Float = 1;
	public var scoreSkillBonusRequirement:Int = 5;
	public var scoreSkillBonusMultiplier:Float = 1;

	public function new(id:String) {
		this.id = id;
		var rawJson = Paths.getTextFromFile('data/gamemodes/$id.json');
		var rawData:GamemodeData = cast Json.parse(rawJson);

		// I'm sorry
		// this.name = rawData.name;
		// this.description = rawData.description;
		if (rawData.color != null)
			this.color = FlxColor.fromString(rawData.color);

		if (rawData.cylinderSize != null)
			this.cylinderSize = rawData.cylinderSize;
		if (rawData.cylinderLiveCount != null)
			this.cylinderLiveCount = rawData.cylinderLiveCount;
		if (rawData.cylinderReloadOnNoLives != null)
			this.cylinderReloadOnNoLives = rawData.cylinderReloadOnNoLives;
		if (rawData.cylinderInitialDamage != null)
			this.cylinderInitialDamage = rawData.cylinderInitialDamage;
		if (rawData.cylinderDamageChangeOnLive != null)
			this.cylinderDamageChangeOnLive = rawData.cylinderDamageChangeOnLive;
		if (rawData.cylinderDamageChangeOnBlank != null)
			this.cylinderDamageChangeOnBlank = rawData.cylinderDamageChangeOnBlank;
		if (rawData.cylinderTrueRandomness != null)
			this.cylinderTrueRandomness = rawData.cylinderTrueRandomness;

		if (rawData.skillsFixedPool != null)
			this.skillsFixedPool = rawData.skillsFixedPool;
		if (rawData.skillsExhaustible != null)
			this.skillsExhaustible = rawData.skillsExhaustible;
		if (rawData.skillsReplenishCountOnLive != null)
			this.skillsReplenishCountOnLive = rawData.skillsReplenishCountOnLive;
		if (rawData.skillsReplenishCountOnBlank != null)
			this.skillsReplenishCountOnBlank = rawData.skillsReplenishCountOnBlank;
		if (rawData.skillsRandomPool != null)
			this.skillsRandomPool = rawData.skillsRandomPool;
		if (this.skillsRandomPool[0] == 'all')
			this.skillsRandomPool = Paths.readDirectories('data/skills', 'data/skills/skillList.txt', 'json');
		if (rawData.skillsCostMultiplier != null)
			this.skillsCostMultiplier = rawData.skillsCostMultiplier;

		if (rawData.scoreWinBonusMultiplier != null)
			this.scoreWinBonusMultiplier = Math.max(0, rawData.scoreWinBonusMultiplier);
		if (rawData.scoreEdgingBonusMultiplierRange != null)
			this.scoreEdgingBonusMultiplierRange = rawData.scoreEdgingBonusMultiplierRange;
		if (rawData.scoreSkillBonusRequirement != null)
			this.scoreSkillBonusRequirement = Std.int(Math.max(1, rawData.scoreSkillBonusRequirement));
		if (rawData.scoreSkillBonusMultiplier != null)
			this.scoreSkillBonusMultiplier = Math.max(0, rawData.scoreSkillBonusMultiplier);
	}

	public function toString():String {
		return 'Gamemode(id: ${id})';
	}
}
