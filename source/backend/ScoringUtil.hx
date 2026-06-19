package backend;

import backend.enums.ScoreRank;
import objects.Character;
import backend.typedefs.ScoreData;

class ScoringUtil {
	public static final WIN_BONUS:Int = 1800;
	public static final EDGING_BONUS:Int = 6400;
	public static final SKILL_BONUS:Int = 1800;

	public static function getMaxScore() {
		return
			WIN_BONUS * Gameplay.currentGamemode.scoreWinBonusMultiplier +
			EDGING_BONUS * Gameplay.currentGamemode.scoreEdgingBonusMultiplierRange[1] +
			SKILL_BONUS * Gameplay.currentGamemode.scoreSkillBonusMultiplier;
	}

	public static function getMinScore() {
		return getMinEdgingBonus();
	}

	public static function judgeWinBonus(char:Character):Int {
		return Math.round((char.currentPressure <= char.maxPressure) ? WIN_BONUS * Gameplay.currentGamemode.scoreWinBonusMultiplier : 0);
	}

	public static function judgeEdgingBonus(char:Character):Int {
		// If character did not win, give them some pity points.
		// If character did not inflate at all, give them full edging bonus.
		// Else give them a fraction of the edging bonus based on how much they inflated.
		if (char.getPressurePercentage() > 1)
			return getMinEdgingBonus();
		if (char.currentPressure == 0)
			return Math.round(EDGING_BONUS);
		return Math.round(FlxMath.lerp(Gameplay.currentGamemode.scoreEdgingBonusMultiplierRange[0], Gameplay.currentGamemode.scoreEdgingBonusMultiplierRange[1], char.getPressurePercentage()) * EDGING_BONUS);
	}

	public static function getMinEdgingBonus() {
		return Math.round(EDGING_BONUS * Gameplay.currentGamemode.scoreEdgingBonusMultiplierRange[0]);
	}

	public static function judgeSkillBonus(char:Character):Int {
		return Math.round(Math.min(char.skillUseCount, Gameplay.currentGamemode.scoreSkillBonusRequirement) / Gameplay.currentGamemode.scoreSkillBonusRequirement * SKILL_BONUS * Gameplay.currentGamemode.scoreSkillBonusMultiplier);
	}

	public static function judgeCharacter(char:Character):ScoreData {
		var sum:Int = 0;
		var winBonus:Int = judgeWinBonus(char);
		sum += winBonus;
		var edgingBonus:Int = judgeEdgingBonus(char);
		sum += edgingBonus;
		var skillBonus:Int = judgeSkillBonus(char);
		sum += skillBonus;
		return {
			charID: char.id,
			cpuControlled: char.cpuControlled,
			charPressure: char.getPressurePercentage(),
			winBonus: winBonus,
			edgingBonus: edgingBonus,
			skillBonus: skillBonus
		}
	}

	public static function calculateScoreToPercent(score:Int, multiplied:Bool = false):Float {
		return FlxMath.roundDecimal(score / getMaxScore(), 2) * (multiplied ? 100 : 1);
	}

	public static function gradePercent(percent:Float):ScoreRank {
		return switch (percent) {
			case (_ >= 1) => true: // 100%
				ScoreRank.P;
			case (_ >= 0.9) => true: // 90% - 99%
				ScoreRank.S;
			case (_ >= 0.8) => true: // 80% - 89%
				ScoreRank.A;
			case (_ >= 0.7) => true: // 70% - 79%
				ScoreRank.B;
			case (_ >= 0.6) => true: // 60% - 69%
				ScoreRank.C;
			case (_ >= 0.5) => true: // 50% - 59%
				ScoreRank.D;
			default: // 0% - 49%
				ScoreRank.F;
		}
	}

	public static function judgeGame(arr:Array<Character>):Array<ScoreData> {
		var scores:Array<ScoreData> = [];
		for (char in arr) {
			scores.push(judgeCharacter(char));
		}
		return scores;
	}
}