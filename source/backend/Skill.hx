package backend;

import backend.typedefs.SkillMetadata;
import tjson.TJSON as Json;

class Skill {
	public var id:String = 'null';
	public var cost:Float = 0;

	// public var name:String = 'Unnamed';
	// public var description:String = 'No description.';
	public var defaultCost:Int = 0;
	public var offensive:Bool = false;
	public var cpuConservePreferred:Bool = false;
	public var cpuUseOnce:Bool = true;

	public function new(id:String, cost:Null<Float> = null, costMultiplier:Float = 1) {
		this.id = id;

		var rawJson = Paths.getTextFromFile('data/skills/' + id + '.json');
		var json:SkillMetadata = cast Json.parse(rawJson);

		this.defaultCost = json.defaultCost;
		this.offensive = json.offensive;
		this.cost = Math.ceil(((cost != null) ? Std.int(cost) : this.defaultCost) * costMultiplier);

		// this.name = json.name;
		// this.description = json.description;
	}

	public function toString():String {
		return 'Skill(id: ${id} | cost: ${cost})';
	}
}