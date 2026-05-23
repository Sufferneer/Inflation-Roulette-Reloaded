package ui.objects;

import backend.enums.AchievementType;
import backend.typedefs.AchievementData;

class AchievementProgressBar extends FlxSpriteGroup {
	var completion:FlxSprite;
	var progressBarBG:FlxSprite;
	var progressBar:FlxSprite;
	var progressTextWhite:FlxText;
	var progressTextBlack:FlxText;

	var progressList:FlxSpriteGroup;

	var progressBarTween:FlxTween;

	public function new(x:Float = 0, y:Float = 0) {
		super();

		completion = new FlxSprite().loadGraphic(Paths.image('ui/menus/achievements/completion'));
		completion.loadGraphic(Paths.image('ui/menus/achievements/completion'), true, Std.int(completion.height), Std.int(completion.height));
		completion.animation.add('true', !Preferences.data.enablePhotosensitiveMode ? [1, 0, 1, 0, 1] : [1], 24, false);
		completion.animation.add('false', [0], 24, false);
		add(completion);

		progressBarBG = new FlxSprite().loadGraphic(Paths.image('ui/menus/achievements/progressBarBG'));
		progressBarBG.x = completion.width - 5;
		progressBarBG.y = (completion.height - progressBarBG.height) / 4;
		add(progressBarBG);

		progressBar = new FlxSprite().loadGraphic(Paths.image('ui/menus/achievements/progressBar'));
		progressBar.x = progressBarBG.x + 10;
		progressBar.y = progressBarBG.y + 10;
		add(progressBar);

		progressTextWhite = new FlxText(0, 0, 0, '0 / 0', 48);

		progressTextBlack = new FlxText(0, 0, 0, '0 / 0', 48);
		progressTextBlack.color = 0xFF000000;
		progressTextBlack.font = progressTextWhite.font = Paths.font('default', false);
		progressTextBlack.angle = progressTextWhite.angle = -2.5;
		add(progressTextBlack);
		add(progressTextWhite);

		progressList = new FlxSpriteGroup();
		add(progressList);

		// Width and height breaks unless we do this
		this.x = x;
		this.y = y;
	}

	public function reloadProgress(data:AchievementData, progress:Array<Dynamic>) {
		completion.animation.play('${!Achievements.isLocked(data.id)}');
		progressBarBG.updateHitbox();
		progressBar.updateHitbox();
		var targetWidth:Float = 0;
		switch (data.type) {
			case NUMBER:
				targetWidth = progressBar.width * (progress[0] / data.target);
				progressTextWhite.text = progressTextBlack.text = '${progress[0]} / ${data.target}';
			case LIST:
				var completedItems = [];
				for (item in progress) {
					if (data.items.contains(item))
						completedItems.push(item);
				}
				targetWidth = progressBar.width * (completedItems.length / data.items.length);
				progressTextWhite.text = progressTextBlack.text = '${completedItems.length} / ${data.items.length}';
			case BOOLEAN:
				targetWidth = progress[0] == true ? progressBar.width : 0;
				progressTextWhite.text = progressTextBlack.text = '';
		}
		progressTextBlack.updateHitbox();
		progressTextWhite.updateHitbox();
		progressTextBlack.x = progressTextWhite.x = progressBar.x + (progressBar.width - progressTextWhite.width) / 2;
		progressTextBlack.y = progressTextWhite.y = progressBar.y + (progressBar.height - progressTextWhite.height) / 2 + 2;
		if (progressBarTween != null)
			progressBarTween.cancel();
		progressBarTween = FlxTween.num((progressBar.clipRect != null ? progressBar.clipRect.width : 0), targetWidth, 0.375, {
			ease: FlxEase.quadOut,
			startDelay: 0.1,
			onComplete: function(_) {
				if (progressBar.clipRect.width == progressBar.width) {
					SuffState.playUISound(Paths.sound('ui/achievements/sparkle'), 0.625);
					completion.animation.play('true');
				}
			}
		}, function(num:Float) {
			completion.animation.play('false');
			progressBar.clipRect = new FlxRect(0, 0, num, progressBar.height);
			progressTextWhite.clipRect = new FlxRect(Math.max(0, num - ((progressTextWhite.x - this.x) - (progressBar.x - this.x))), 0,
				progressTextWhite.width, progressTextWhite.height);
		});

		progressList.clear();
		if (data.type != LIST)
			return;
		var leWidth = this.width;
		var leHeight = this.height;
		var progressListColumns = Math.ceil(Math.sqrt(data.items.length));
		// Store dimensions temporarily since dimensions are dynamic
		for (num => item in data.items) {
			var text:FlxText = new FlxText(0, 0, 0, Language.getPhrase(data.itemTranslationKey.replace('%', item)), 32);
			if (!progress.contains(item)) {
				text.color = 0xFF808080;
				if (data.hideItems)
					text.text = Utilities.replaceWithSubstr(text.text, '?');
			}
			text.size = Std.int(Math.min(32, (leWidth / progressListColumns) / (text.width + 16) * 32));
			text.fieldWidth = leWidth / progressListColumns;
			text.alignment = CENTER;
			text.x = leWidth / progressListColumns * (num % progressListColumns);
			text.y = leHeight + 16 + 48 * Math.floor(num / progressListColumns) + (32 - text.size) / 2;
			progressList.add(text);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
