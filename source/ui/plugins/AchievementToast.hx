package ui.plugins;

import flixel.graphics.FlxGraphic;
import ui.objects.AchievementIcon;

class AchievementToast extends FlxSpriteGroup {
	public static var instance:Null<AchievementToast> = null;
	public static var queue:Array<String> = [];
	public static var displayedText:String = '';

	var bg:FlxSprite;
	var icon:AchievementIcon;
	var text:FlxText;

	public function new() {
		super();

		FlxGraphic.defaultPersist = true;

		scrollFactor.set();

		bg = new FlxSprite().makeGraphic(540, 150, 0xFF000000);
		add(bg);

		icon = new AchievementIcon(10, 10, '', false);
		add(icon);

		text = new FlxText(0, 0, 540 - icon.height - 40, '', 32);
		add(text);

		FlxGraphic.defaultPersist = false;
	}

	public static function initialize() {
		FlxG.plugins.drawOnTop = true;
		instance = new AchievementToast();
		instance.x = (FlxG.width - instance.width) / 2;
		instance.y = FlxG.height;
		FlxG.plugins.add(instance);
	}

	public function dequeue() {
		tick = 0;
		instance.y = FlxG.height;

		var id = queue[0];

		instance.icon.loadIconGraphic(id, false);
		instance.icon.alpha = 0;
		displayedText = Language.getPhrase('achievementToast.title') + '\n' + Language.getPhrase('achievement.$id.name');
		instance.text.color = 0xFFFFFFFF;
		instance.text.font = Paths.font('default');
		instance.text.text = displayedText;
		instance.text.updateHitbox();
		instance.text.x = instance.x + instance.icon.width + 20;
		instance.text.y = instance.y + (instance.bg.height - instance.text.height) / 2;
		instance.text.text = '';

		FlxTween.tween(instance, {y: FlxG.height - instance.height - 20}, 0.5, {
			ease: FlxEase.backOut,
			onStart: function(_) {
				SuffState.playUISound(Paths.sound('ui/achievements/achievement' + Achievements
				.achievementsList.get(id).tier), 0.75);
			}
		});
		new FlxTimer().start(0.75, function(_) {
			instance.icon.scale.set(2, 2);
			instance.icon.angle = -30;
			FlxTween.tween(instance.icon, {
				angle: 10,
				alpha: 1,
				'scale.x': 0.75,
				'scale.y': 0.75}, 0.25 + 1 / 6, {
				ease: FlxEase.expoIn,
				onComplete: function(_) {
					instance.text.color = Constants.ACHIEVEMENT_TIER_COLORS.get(Achievements.achievementsList.get(id).tier);
					FlxTween.tween(instance.text, {'scale.x': 1.05, 'scale.y': 1.05}, 0.05, {
						ease: FlxEase.quintOut,
						onComplete: function(_) {
							FlxTween.tween(instance.text, {'scale.x': 1, 'scale.y': 1}, 0.05, {
								ease: FlxEase.bounceOut
							});
						}
					});
					FlxTween.tween(instance.bg, {'scale.x': 1.05, 'scale.y': 1.05}, 0.1, {
						ease: FlxEase.quintOut,
						onComplete: function(_) {
							FlxTween.tween(instance.bg, {'scale.x': 1, 'scale.y': 1}, 0.1, {
								ease: FlxEase.bounceOut
							});
						}
					});
					FlxTween.tween(instance.icon, {angle: 0, 'scale.x': 1, 'scale.y': 1}, 0.25, {
						ease: FlxEase.bounceOut
					});
				}
			});
		});
	}

	static var tick:Float = 5;

	public static function enqueue(id:String) {
		queue.push(id);
		if (queue.length == 1)
			instance.dequeue();
	}

	override function update(elapsed:Float) {
		if (instance == null) {
			return;
		}
		instance.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		if (tick < 5)
			tick += elapsed;
		if (tick >= 1 / 24 && tick <= 23 / 24) {
			instance.text.text = displayedText.substr(0, Std.int(displayedText.length * (tick - 1 / 24) / (23 / 24)));
		} else {
			instance.text.text = displayedText;
		}

		if (tick > 3.5 && tick < 5) {
			instance.y = FlxG.height - instance.height - 20 + (tick - 3.5) * 120;
		}
		if (tick >= 5) {
			queue.shift();
			if (queue.length > 0)
				instance.dequeue();
		}

		super.update(elapsed);
	}
}
