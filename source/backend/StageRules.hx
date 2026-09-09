package backend;

import backend.typedefs.StageRulesData;
import objects.Character;

class StageRules {
	public var allowConfidenceOverflow:Bool = false;
	public var skillTurnCostChange:Float = 0;
	public var timeLimit:Float = -1;
	public var confidenceChangeForElimination:Float = 0;
	public var pressureTurnChangeBase:Float = 0;
	public var pressureTurnChangeFactor:Float = 0;

	public function new(data:Null<StageRulesData> = null) {
		allowConfidenceOverflow = data?.allowConfidenceOverflow ?? false;
		skillTurnCostChange = data?.skillTurnCostChange ?? 0;
		timeLimit = data?.timeLimit ?? 0;
		confidenceChangeForElimination = data?.confidenceChangeForElimination ?? 0;
		pressureTurnChangeBase = data?.pressureTurnChangeBase ?? 0;
		pressureTurnChangeFactor = data?.pressureTurnChangeFactor ?? 0;
	}

	public function toString():String {
		return 'StageRules(allowConfidenceOverflow: $allowConfidenceOverflow, skillTurnCostChange: $skillTurnCostChange, timeLimit: $timeLimit, confidenceChangeForElimination: $confidenceChangeForElimination)';
	}

	inline public function hasTimeLimit() {
		return (this.timeLimit > 0);
	}

	inline public function getTurnPressureChange(character:Character) {
		return this.pressureTurnChangeBase + character.currentPressure * this.pressureTurnChangeFactor;
	}
}
