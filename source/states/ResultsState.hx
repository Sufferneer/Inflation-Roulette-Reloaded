package states;

import backend.typedefs.ScoreData;
import flixel.group.FlxSpriteContainer;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxGridOverlay;
import backend.ScoringUtil;
import backend.enums.SuffTransitionStyle;

class ResultsState extends SuffState {
	var barGroup:FlxSpriteGroup;
	var textGroup:FlxSpriteContainer;
	var totalScoreGroup:FlxTypedSpriteGroup<FlxText>;
	var characterGroup:FlxTypedContainer<FlxSprite>;
	var resultsTitleGroup:FlxTypedSpriteContainer<FlxText>;
	var resultsDescGroup:FlxTypedSpriteContainer<FlxText>;
	var grid:FlxBackdrop;
	var barLeaderboard:FlxSprite;
	var barUp:FlxSprite;
	var barUpColored:FlxSprite;
	var barDown:FlxSprite;
	var barDownColored:FlxSprite;
	var leaderboardGroup:FlxTypedSpriteGroup<FlxText>;
	var goodPlayersText:FlxBackdrop;
	var badPlayersText:FlxBackdrop;
	var blackGroup:FlxSpriteGroup;
	public static var data:Array<ScoreData> = [];
	var achievementsToEarn:Array<String> = [];
	var totalScore:Array<Int> = [];
	var highestScore:Float = 0;
	var highestScoreIndices:Array<Int> = [];
	override public function create():Void {
		for (num => what in data) {
			var jesus = what.winBonus + what.edgingBonus + what.skillBonus;
			if (jesus > highestScore) highestScore = jesus;
			totalScore.push(jesus);
		}
		for (num => what in data) {
			var jesus = what.winBonus + what.edgingBonus + what.skillBonus;
			if (jesus == highestScore)
				highestScoreIndices.push(num);
			if (Achievements.enabled && !what.cpuControlled) {
				if (jesus >= ScoringUtil.getMaxScore() && Achievements.isLocked('maximumScore'))
					achievementsToEarn.push('maximumScore');
				if (jesus <= ScoringUtil.getMinScore() && Achievements.isLocked('minimumScore'))
					achievementsToEarn.push('minimumScore');
			}
		}
		allowSkip = achievementsToEarn.length <= 0;
		trace(achievementsToEarn);

		Window.setTitle(Language.getPhrase('resultsMenu.windowDisplay'));

		super.create();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFAA80FF);
		add(bg);

		barUp = new FlxSprite().makeGraphic(FlxG.width, 16 * 4, 0xFF4000C0);
		barUp.x = FlxG.width;
		FlxTween.tween(barUp, {x: 0}, 0.2, {startDelay: 0.2});

		barUpColored = new FlxSprite();
		barUpColored.visible = false;

		barDown = new FlxSprite().makeGraphic(FlxG.width, Std.int(barUp.height), 0xFF4000C0);
		barDown.y = FlxG.height - barDown.height;
		barDown.x = -barDown.width;
		FlxTween.tween(barDown, {x: 0}, 0.2, {startDelay: 0.2});

		barDownColored = new FlxSprite();
		barDownColored.y = barDown.y;
		barDownColored.visible = false;

		var colorArray = [];
		for (i in highestScoreIndices) {
			colorArray.push(Constants.PLAYER_COLORS[i]);
			colorArray.push(Constants.PLAYER_COLORS[i]);
			colorArray.push(Constants.PLAYER_COLORS[i]);
		}
		var barGraphic = FlxGradient.createGradientBitmapData(FlxG.width, 16 * 4, colorArray, 16 * 4, 0);
		barUpColored.loadGraphic(barGraphic);
		barDownColored.loadGraphic(barGraphic);

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFFFFFFF, 0x00));
		grid.velocity.set(-40, -40);
		grid.alpha = 0;

		var text = new FlxText(0, 0, Language.getPhrase('resultsMenu.bestPlayer' + (highestScoreIndices.length > 1 ? 's' : '')), 640);
		while (text.width > FlxG.width / 2) {
			text.size -= 16;
		}
		goodPlayersText = new FlxBackdrop(text.graphic.bitmap, Y);
		goodPlayersText.x = Std.int((FlxG.width / 2 - goodPlayersText.width) / 2);
		goodPlayersText.alpha = 0;
		goodPlayersText.velocity.y = -20;

		var text = new FlxText(0, 0, Language.getPhrase('resultsMenu.badPlayer' + ((data.length - highestScoreIndices.length) > 1 ? 's' : '')), 640);
		while (text.width > FlxG.width / 2) {
			text.size -= 16;
		}
		badPlayersText = new FlxBackdrop(text.graphic.bitmap, Y);
		badPlayersText.x = Std.int(FlxG.width / 2 + (FlxG.width / 2 - badPlayersText.width) / 2);
		badPlayersText.alpha = 0;
		badPlayersText.visible = highestScoreIndices.length != data.length;
		badPlayersText.velocity.y = 20;

		barGroup = new FlxSpriteGroup();
		add(barGroup);
		add(goodPlayersText);
		add(badPlayersText);
		add(grid);
		characterGroup = new FlxTypedContainer<FlxSprite>();
		add(characterGroup);

		leaderboardGroup = new FlxTypedSpriteContainer<FlxText>();
		var ranks = [for (i in 0...data.length) i];
		ranks.sort((a, b) -> {
			if (totalScore[a] > totalScore[b]) return -1;
			else if (totalScore[a] < totalScore[b]) return 1;
			return 0;
		});
		for (i in 0...ranks.length) {
			if (ranks[i] == highestScore)
				ranks[i] = 0;
		}
		trace(ranks);
		barLeaderboard = new FlxSprite().makeGraphic(FlxG.width, 192, 0xFF000000);
		barLeaderboard.alpha = 0.25;
		barLeaderboard.y = barUp.height - barLeaderboard.height;
		add(barLeaderboard);
		for (rank => playerNum in ranks) {
			var leData = data[playerNum];
			var isCPU:Bool = data[playerNum].cpuControlled;
			var isWinner:Bool = highestScoreIndices.contains(playerNum);
			var hasDuplicate:Bool = [for (char in data) if (char.charID == leData.charID) char.charID].length > 1;
			var playerStr = Language.getPhrase('resultsMenu.leaderboard.player' + (hasDuplicate ? 'Duplicate' : '') + 'Format', [Language.getPhrase('resultsMenu.leaderboard.playerType.' + (isCPU ? 'cpu' : 'human'), [], ''), Language.getPhrase('character.${leData.charID}.name.short'), playerNum + 1]);
			var str = Language.getPhrase('resultsMenu.leaderboard.format' + (isWinner ? '' : '.reversed'), ['${rank + 1}', playerStr, totalScore[playerNum], ScoringUtil.gradePercent(ScoringUtil.calculateScoreToPercent(totalScore[playerNum]))]);
			var text = new FlxText(0, 0, str, 32);
			text.y = barUp.height + rank * (text.height + 8);
			text.color = Constants.PLAYER_COLORS[playerNum];
			if (leData.charPressure > 1) {
				var outlineColor = text.color;
				text.setBorderStyle(OUTLINE, outlineColor, 0.25);
			}
			if (leData.cpuControlled) {
				text.color.saturation *= 0.5;
				text.alpha = 0.75;
			}
			// Target X
			text.mass = isWinner ? 16 : FlxG.width - text.width - 16;
			text.x = isWinner ? -text.width : FlxG.width;
			leaderboardGroup.add(text);
		}
		add(leaderboardGroup);

		textGroup = new FlxSpriteContainer();
		add(textGroup);
		blackGroup = new FlxSpriteGroup();
		add(blackGroup);
		totalScoreGroup = new FlxTypedSpriteGroup<FlxText>();
		add(totalScoreGroup);
		add(barUpColored);
		add(barUp);
		add(barDownColored);
		add(barDown);
		resultsTitleGroup = new FlxTypedSpriteContainer<FlxText>();
		add(resultsTitleGroup);
		resultsDescGroup = new FlxTypedSpriteContainer<FlxText>();
		add(resultsDescGroup);
		for (i in 0...data.length) {
			var black = new FlxSprite(i * FlxG.width / data.length).makeGraphic(1, FlxG.height, 0xFF001999);
			black.scale.x = FlxG.width / data.length;
			black.updateHitbox();
			black.alpha = 0;
			blackGroup.add(black);

			var bar = new FlxSprite(i * FlxG.width / data.length).makeGraphic(Math.round(FlxG.width / data.length), FlxG.height, 0xFFFFFFFF);
			var leColor = Constants.PLAYER_COLORS[i];
			leColor = Utilities.getLighterShade(leColor, 0.5);
			bar.color = leColor;
			if (i % 2 == 0) {
				bar.y = -bar.height;
			} else {
				bar.y = FlxG.height;
			}
			bar.alpha = 0.625;
			FlxTween.tween(bar, {y: 0}, 0.5, {
				startDelay: 0.5 + i * 0.2,
				ease: FlxEase.cubeOut
			});
			barGroup.add(bar);

			var spriteExists:Bool = Paths.fileExists(Paths.getImagePath('ui/menus/results/characters/${data[i].charID}'));
			var char:FlxSprite = new FlxSprite();
			if (spriteExists) {
				char.frames = Paths.sparrowAtlas('ui/menus/results/characters/${data[i].charID}');
			} else {
				char.frames = Paths.sparrowAtlas('ui/menus/results/characters/goober');
			}
			var suffix = data[i].charPressure <= 1 ? 'Standing' : 'Defeated';
			char.animation.addByPrefix('idle', 'idle${suffix}0', 24, true);
			char.animation.addByPrefix('win', 'win${suffix}0', FlxG.random.int(18, 30), false);
			char.animation.addByPrefix('win-loop', 'win${suffix}Loop0', 24, true);
			char.animation.addByPrefix('lose', 'lose${suffix}0', 24, false);
			char.animation.addByPrefix('lose-loop', 'lose${suffix}Loop0', 24, true);
			char.animation.play('idle', true, false, FlxG.random.int(0, char.animation.getByName('idle').numFrames - 1));
			char.animation.onFinish.add(function(anim:String) {
				if ((anim.startsWith('win')) && !anim.endsWith('-loop'))
					char.animation.play(anim + '-loop', true, false, FlxG.random.int(0, char.animation.getByName(anim + '-loop').numFrames - 1));
			});
			if (!spriteExists) {
				char.alpha = 0.325;
				char.color = 0xFF000000;
			}
			char.x = bar.x + (bar.width - char.width) / 2;
			char.y = FlxG.height;
			FlxTween.tween(char, {y: FlxG.height - char.height}, 2, {ease: FlxEase.cubeInOut, startDelay: 0.8 + 0.1 * (i + 1)});
			characterGroup.add(char);

			var winBonusTxt:FlxText = new FlxText(bar.x + 50, barUp.height + 20, FlxG.width / data.length - 140, Language.getPhrase('resultsMenu.winBonus'), 32);
			winBonusTxt.font = Paths.font('small');
			winBonusTxt.ID = i;
			while (winBonusTxt.height > 96) {
				winBonusTxt.size -= 8;
			}
			textGroup.add(winBonusTxt);
			var winBonusScore:FlxText = new FlxText(bar.x + 20, 0, FlxG.width / data.length - 40, '', 32);
			winBonusScore.y = winBonusTxt.y + (winBonusTxt.height - winBonusScore.height) / 2;
			winBonusScore.ID = i;
			winBonusScore.alignment = RIGHT;
			new FlxTimer().start(0.5 + i * 0.2, function(_) {
				FlxTween.num(0, data[i].winBonus, 1, {ease: FlxEase.quintOut}, function(num:Float) {
					winBonusScore.text = '${Std.int(num)}';
				});
			});
			textGroup.add(winBonusScore);

			final textSpacing:Float = 60;

			var edgingBonusTxt:FlxText = new FlxText(winBonusTxt.x, winBonusTxt.y + winBonusTxt.height + textSpacing, winBonusTxt.width, Language.getPhrase('resultsMenu.edgingBonus'), 32);
			edgingBonusTxt.ID = i;
			edgingBonusTxt.font = winBonusTxt.font;
			if (data[i].charPressure <= 0) edgingBonusTxt.text = Language.getPhrase('resultsMenu.edgingBonus.alt');
			while (edgingBonusTxt.height > 96) {
				edgingBonusTxt.size -= 8;
			}
			textGroup.add(edgingBonusTxt);
			var edgingBonusScore:FlxText = new FlxText(winBonusScore.x, 0, FlxG.width / data.length - 40, '', 32);
			edgingBonusScore.ID = i;
			edgingBonusScore.y = edgingBonusTxt.y + (edgingBonusTxt.height - edgingBonusScore.height) / 2;
			edgingBonusScore.alignment = RIGHT;
			new FlxTimer().start(0.5 + i * 0.2, function(_) {
				FlxTween.num(0, data[i].edgingBonus, 1, {ease: FlxEase.quintOut}, function(num:Float) {
					edgingBonusScore.text = '${Std.int(num)}';
				});
			});
			textGroup.add(edgingBonusScore);

			var skillBonusTxt:FlxText = new FlxText(edgingBonusTxt.x, edgingBonusTxt.y + edgingBonusTxt.height + textSpacing, edgingBonusTxt.width, Language.getPhrase('resultsMenu.skillBonus'), 32);
			skillBonusTxt.ID = i;
			skillBonusTxt.font = edgingBonusTxt.font;
			while (skillBonusTxt.height > 96) {
				skillBonusTxt.size -= 8;
			}
			textGroup.add(skillBonusTxt);
			var skillBonusScore:FlxText = new FlxText(edgingBonusScore.x, 0, FlxG.width / data.length - 40, '', 32);
			skillBonusScore.ID = i;
			skillBonusScore.y = skillBonusTxt.y + (skillBonusTxt.height - skillBonusScore.height) / 2;
			skillBonusScore.alignment = RIGHT;
			new FlxTimer().start(0.5 + i * 0.2, function(_) {
				FlxTween.num(0, data[i].skillBonus, 1, {ease: FlxEase.quintOut}, function(num:Float) {
					skillBonusScore.text = '${Std.int(num)}';
				});
			});
			textGroup.add(skillBonusScore);

			var plus:FlxText = new FlxText(bar.x + 10, skillBonusScore.y, '+', 48);
			plus.elasticity = 1;
			plus.ID = i;
			textGroup.add(plus);

			var line:FlxSprite = new FlxSprite(i * FlxG.width / data.length, skillBonusTxt.y + skillBonusTxt.height + textSpacing).makeGraphic(Std.int(FlxG.width / data.length), 6, 0xFFFFFFFF);
			line.ID = i;
			textGroup.add(line);

			var totalScore:FlxText = new FlxText(plus.x + 10, line.y + line.height + textSpacing, FlxG.width / data.length - 40, 80);
			totalScore.color = 0xFFFF00;
			totalScore.alignment = RIGHT;
			totalScore.ID = i;
			totalScoreGroup.add(totalScore);

			var winBonusTxtY = winBonusTxt.y;
			winBonusTxt.y = -winBonusTxt.height;
			var winBonusScoreY = winBonusScore.y;
			winBonusScore.y = -winBonusScore.height;
			var edgingBonusTxtY = edgingBonusTxt.y;
			edgingBonusTxt.y = -edgingBonusTxt.height;
			var edgingBonusScoreY = edgingBonusScore.y;
			edgingBonusScore.y = -edgingBonusScore.height;
			var skillBonusTxtY = skillBonusTxt.y;
			skillBonusTxt.y = -skillBonusTxt.height;
			var skillBonusScoreY = skillBonusScore.y;
			skillBonusScore.y = -skillBonusScore.height;
			var plusY = plus.y;
			plus.y = -plus.height;
			var lineY = line.y;
			line.y = -line.height;
			FlxTween.tween(winBonusTxt, {y: winBonusTxtY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.05 * i});
			FlxTween.tween(winBonusScore, {y: winBonusScoreY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.05 + 0.05 * i});
			FlxTween.tween(edgingBonusTxt, {y: edgingBonusTxtY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.2 + 0.05 * i});
			FlxTween.tween(edgingBonusScore, {y: edgingBonusScoreY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.25 + 0.05 * i});
			FlxTween.tween(skillBonusTxt, {y: skillBonusTxtY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.4 + 0.05 * i});
			FlxTween.tween(skillBonusScore, {y: skillBonusScoreY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.45 + 0.05 * i});
			FlxTween.tween(plus, {y: plusY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.6 + 0.05 * i});
			FlxTween.tween(line, {y: lineY}, 0.3, {ease: FlxEase.backOut, startDelay: 0.65 + 0.05 * i});
			var sadGold:Array<FlxSprite> = [winBonusScore, edgingBonusScore, skillBonusScore, plus, line, totalScore];
			var g:Array<FlxSprite> = [winBonusTxt, edgingBonusTxt, skillBonusTxt];

			new FlxTimer().start(1.6, function(_) {
				FlxTween.tween(winBonusTxt, {alpha: 0.5}, 1);
				FlxTween.tween(edgingBonusTxt, {alpha: 0.5}, 1);
				FlxTween.tween(skillBonusTxt, {alpha: 0.5}, 1);
				moveShit(sadGold, 15, 40, g);
				new FlxTimer().start(0.3, function(_) {
					moveShit(sadGold, 10, 20, g);
					new FlxTimer().start(0.3, function(_) {
						moveShit(sadGold, 5, 0, g);
						// doTotalScoreShit();
					});
				});
			});
		}

		new FlxTimer().start(2.2, function(_) {
			doTotalScoreShit();
		});

		var resultsStr = Language.getPhrase('resultsMenu.title');
		var width:Float = 20;
		for (i in 0...resultsStr.length) {
			var text:FlxText = new FlxText(FlxG.width, 0, resultsStr.substr(i, 1), Std.int(Math.max(1, barUp.height / 16)) * 16);
			text.ID = i;
			text.angle = 20;
			FlxTween.tween(text, {x: width}, 0.1, {
				startDelay: 1.3 / resultsStr.length * (i + 1),
				onComplete: function(_) {
					FlxTween.tween(text, {'scale.x': 0.75, 'scale.y': 1.5, angle: -10}, 0.1, {
						onComplete: function(_) {
							FlxTween.tween(text, {'scale.x': 1.25, 'scale.y': 0.825, angle: 5}, 0.1, {
								onComplete: function(_) {
									FlxTween.tween(text, {'scale.x': 1, 'scale.y': 1, angle: 0}, 0.1);
								}
							});
						}
					});
				}
			});
			width += text.width;
			resultsTitleGroup.add(text);
		}
		var resultsDescStr = Language.getPhrase('resultsMenu.instructions');
		width = FlxG.width;
		for (i in 0...resultsDescStr.length) {
			var text:FlxText = new FlxText(width, barDown.y, resultsDescStr.substr(i, 1), Std.int(Math.max(1, barDown.height / 16)) * 16);
			width += text.width;
			resultsDescGroup.add(text);
		}

		SuffState.playMusic('resultsStart');
	}

	function moveShit(objects:Array<FlxSprite>, offsetFirst:Float = 10, offset:Float = 10, children:Array<FlxSprite>) {
		var what = barUp.y + barUp.height + offsetFirst;
		for (num => i in objects) {
			FlxTween.tween(i, {y: what}, 0.3, {ease: FlxEase.bounceOut, onUpdate: function(_) {
				if (children[num] != null) {
					children[num].y = i.y + (i.height - children[num].height) / 2;
				}
			}});
			if (num + 1 < objects.length && objects[num + 1].elasticity == 0) {
				what += i.height + offset;
			}
		}
	}

	function doTotalScoreShit() {
		for (num => score in totalScoreGroup.members) {
			FlxTween.tween(blackGroup.members[num], {alpha: 0.375}, 0.3);
			FlxTween.num(0, totalScore[num], 2.2, {ease: FlxEase.quadOut}, function(num:Float) {
				score.text = '${Std.int(num)}';
			});
		}
		new FlxTimer().start(2.2, function(_) {
			for (num => black in blackGroup.members) {
				var isHighest = totalScore[num] >= highestScore;
				if (isHighest) {
					if (Preferences.data.enablePhotosensitiveMode) {
						black.alpha = 0;
					} else {
						FlxFlicker.flicker(black, 0.3, 1 / 30, false);
					}
				} else {
					FlxTween.tween(black, {alpha: 0}, 1.4, {startDelay: 0.2, ease: FlxEase.quadIn});
				}
				characterGroup.members[num].animation.play(isHighest ? 'win' : 'lose', true);
			}
			doRevealAnims();
		});
	}

	function doRevealAnims() {
		var highestNum = 0;
		var loseNum = 0;
		var startX = 350 - 25 * (highestScoreIndices.length - 1);
		var offset = 280 - 40 * (highestScoreIndices.length - 1);
		var order:Array<Int> = [];
		trace(order);
		var loseSum = characterGroup.members.length - highestScoreIndices.length;
		for (charNum => char in characterGroup) {
			var moveLeft = false;
			var moveRight = false;
			if (!highestScoreIndices.contains(charNum)) {
				for (i in highestScoreIndices) {
					if (i - charNum > 0) moveLeft = true;
					if (i - charNum < 0) moveRight = true;
				}
			}
			if (moveLeft || moveRight) { // Lost Characters
				var what = loseNum;
				FlxTween.tween(char, {y: char.y + 40}, 0.5, {ease: FlxEase.cubeOut, onComplete: function(_) {
					FlxTween.tween(char, {y: FlxG.height}, 1, {ease: FlxEase.cubeIn, onComplete: function(_) {
						char.x = FlxG.width;
						char.y = barDown.y - char.height;
						char.animation.play(char.animation.curAnim.name + '-loop', true, false, FlxG.random.int(0, char.animation.getByName(char.animation.curAnim.name + '-loop').numFrames - 1));
						FlxTween.tween(char, {x: FlxG.width * 0.425 + (FlxG.width / 2 - 160 * loseSum) / 2 + 160 * what - char.width / 4}, 1, {ease: FlxEase.cubeInOut});
					}});
				}});
				loseNum++;
				if (moveLeft && !moveRight) // Move Left
					FlxTween.tween(char, {x: char.x - 160}, 0.5, {ease: FlxEase.circOut, onComplete: function(_) {
						FlxTween.tween(char, {x: char.x - FlxG.width - char.width}, 1, {ease: FlxEase.cubeIn});
					}});
				else if (!moveLeft && moveRight) // Move Right
					FlxTween.tween(char, {x: char.x + 160}, 0.5, {ease: FlxEase.circOut, onComplete: function(_) {
						FlxTween.tween(char, {x: char.x + FlxG.width}, 1, {ease: FlxEase.cubeIn});
					}});
			}
			if (!moveLeft && !moveRight) {
				FlxTween.tween(char, {x: startX + offset * highestNum - char.width / 2}, 0.5, {startDelay: 0.5, ease: FlxEase.backInOut});
				FlxTween.tween(char, {y: barDown.y - char.height}, 0.3, {ease: FlxEase.circOut});
				highestNum++;
			}
			FlxTween.tween(textGroup, {y: -FlxG.height}, 0.5, {startDelay: 0.6, ease: FlxEase.cubeIn});
			FlxTween.tween(totalScoreGroup, {y: -FlxG.height}, 0.5, {startDelay: 0.6, ease: FlxEase.cubeIn});
		}
		highestNum = 0;
		for (barNum => bar in barGroup.members) {
			if (highestScoreIndices.contains(barNum)) {
				var leScale = barGroup.members.length / highestScoreIndices.length;
				var leNum = highestNum;
				FlxTween.tween(bar, {x: FlxG.width / highestScoreIndices.length * leNum, 'scale.x': leScale, alpha: 1}, 0.5, {startDelay: 0.5, ease: FlxEase.cubeIn, onUpdate: function(_) {
					bar.updateHitbox();
				}, onComplete: function(_) {
					bar.scale.x = leScale;
					bar.updateHitbox();
					bar.x = FlxG.width / highestScoreIndices.length * leNum;
				}});
				highestNum++;
			} else {
				FlxTween.tween(bar, {alpha: 0}, 0.5, {startDelay: 0.5, ease: FlxEase.cubeIn});
			}
		}
		for (member in textGroup.members) {
			if (!highestScoreIndices.contains(member.ID))
				FlxTween.tween(member, {alpha: 0}, 0.5);
		}
		for (member in totalScoreGroup.members) {
			if (!highestScoreIndices.contains(member.ID))
				FlxTween.tween(member, {alpha: 0}, 0.5);
		}

		barUpColored.visible = barDownColored.visible = true;
		FlxTween.tween(barUp, {alpha: 0}, 0.5);
		FlxTween.tween(barDown, {alpha: 0}, 0.5);

		for (i in achievementsToEarn) {
			Achievements.advanceProgress(i, [true]);
		}

		new FlxTimer().start(1.2, function(_) {
			doPostRevealAnims();
		});
	}

	function doPostRevealAnims() {
		if (isLeaving) return;
		allowSkip = true;
		SuffState.playMusic('resultsLoop');
		FlxTween.tween(goodPlayersText, {alpha: 0.4}, 1);
		FlxTween.tween(badPlayersText, {alpha: 0.4}, 1);
		FlxTween.tween(grid, {alpha: 0.4}, 2);
		for (txt in resultsDescGroup) {
			txt.velocity.x = -160;
		}
		new FlxTimer().start(1, function(_) {
			FlxTween.tween(barLeaderboard, {y: barUp.height}, 2, {ease: FlxEase.cubeInOut});
			for (num => txt in leaderboardGroup.members) {
				FlxTween.tween(txt, {x: txt.mass}, 2, {ease: FlxEase.cubeOut, startDelay: 0.2 * (num + 1)});
			}
		});
	}

	public static var allowSkip:Bool = true;
	var isLeaving:Bool = false;

	override function update(elapsed:Float) {
		for (num => txt in resultsTitleGroup.members) {
			txt.y = barUp.y + (barUp.height - txt.height) / 2 + 5 - Math.pow(Math.sin(num / resultsTitleGroup.members.length * 180 * Constants.TO_RADIANS - SuffState.timePassedOnState * 4), 2) * 7;
		}
		for (num => txt in resultsDescGroup.members) {
			txt.y = barDown.y + (barDown.height - txt.height) / 2 + 5 - Math.pow(Math.sin(num / resultsDescGroup.members.length * 360 * Constants.TO_RADIANS + SuffState.timePassedOnState * 4), 2) * 7;
			txt.x += txt.velocity.x * elapsed;
			if (txt.x <= -80)
				txt.x = FlxG.width;
		}
		if (allowSkip && !isLeaving) {
			if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed) {
				isLeaving = true;
				Achievements.enabled = true;
				FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.8, {
					onComplete: function(_) {
						SuffState.playMusic('null');
					}
				});
				FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1, {
					onComplete: function(_) {
						FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.4);
					}
				});
				SuffState.switchState(new MainMenuState(), TILES, true);
			}
		}
		super.update(elapsed);
	}
}
