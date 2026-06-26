package states;

import backend.typedefs.AchievementData;
import backend.enums.AchievementTier;
import flixel.effects.FlxFlicker;
import substates.ResetAchievementPrompt;
import ui.objects.AchievementPlaque;
import ui.objects.AchievementProgressBar;
import ui.objects.SuffIconButton;
import objects.particleEmitters.SparkleEmitter;
#if FLX_ACCELEROMETER
import openfl.sensors.Accelerometer;
#end

class AchievementsState extends SuffState {
	var enableInput:Bool = false;

	var exitButton:SuffIconButton;
	var bg:FlxSprite;
	var overlay:FlxSprite;
	var spotlight:FlxSprite;
	var achievementName:FlxText;
	var achievementDescription:FlxText;
	var achievementProgress:AchievementProgressBar;
	var upButton:SuffButton;
	var downButton:SuffButton;
	var resetButton:SuffButton;

	var plaques:FlxTypedContainer<AchievementPlaque> = new FlxTypedContainer<AchievementPlaque>();
	var shelves:FlxTypedContainer<FlxSprite> = new FlxTypedContainer<FlxSprite>();

	final plaquesPerShelf:Int = 4;
	final shelvesPerPage:Int = 2;

	final overlayWidth:Float = FlxG.height / Constants.GOLDEN_RATIO;
	var bgWidth:Float = 0;
	var curPage:Int = 0;
	var lastPage:Int = 0;

	public static var curSelected:Int = 0;
	public static var instance:AchievementsState;

	override function create() {
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		super.create();

		Window.setTitle(Language.getPhrase('achievementsMenu.windowDisplay'));

		persistentDraw = true;
		persistentUpdate = false;

		curSelected = 0;

		bgWidth = FlxG.width - overlayWidth;

		FlxG.camera.follow(cameraPosLerped, LOCKON);

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menus/achievements/bg'));
		bg.screenCenter();
		var ratio = Math.max(FlxG.width / Constants.ORIGINAL_FLXG_WIDTH, FlxG.height / Constants.ORIGINAL_FLXG_HEIGHT);
		bg.scale.set(ratio + 0.2, ratio + 0.2);
		bg.scrollFactor.set(0.8, 0);
		add(bg);

		spotlight = new FlxSprite().loadGraphic(Paths.image('ui/menus/achievements/spotlight'));
		spotlight.alpha = 0.375;
		if (!Preferences.data.decreaseDetail)
			spotlight.blend = ADD;
		spotlight.visible = false;
		add(spotlight);

		add(plaques);

		add(shelves);
		var num:Int = 0;
		for (id in Achievements.achievementIDs) {
			var data:AchievementData = Achievements.achievementsList.get(id);
			var locked:Bool = Achievements.isLocked(id);

			var shelf:FlxSprite = new FlxSprite();
			shelf.loadGraphic(Paths.image('ui/menus/achievements/shelf'));
			shelf.x = (FlxG.width - shelf.width) / 2;
			shelf.y = 300 + 240 * (Math.floor(num / plaquesPerShelf) % shelvesPerPage) + FlxG.height * Math.floor(num / plaquesPerShelf / shelvesPerPage);
			shelves.add(shelf);

			var plaque:AchievementPlaque = new AchievementPlaque(0, 0, data, locked);
			plaque.x = shelf.x + (shelf.width - plaque.width * plaquesPerShelf) / 2 + (plaque.width) * num % plaquesPerShelf;
			plaque.y = shelf.y - plaque.height + shelf.height * 0.25;
			plaque.onHover = function() {
				FlxTween.cancelTweensOf(plaque);
				FlxTween.tween(plaque, {'offset.y': 30, angle: -5}, 0.15, {
					ease: FlxEase.cubeOut
				});
			};
			plaque.onIdle = function() {
				FlxTween.cancelTweensOf(plaque);
				FlxTween.tween(plaque, {'offset.y': 0, angle: 0}, 0.15, {
					ease: FlxEase.cubeOut
				});
			};
			plaque.onClick = function() {
				changeAchievementText(data, Achievements.curProgress.get(id));
				castSpotlight(plaque);
				curSelected = num;
			};
			plaques.add(plaque);
			if (data.hideFromMenu == true && locked)
				plaque.visible = false;
			if (!Preferences.data.decreaseDetail && !locked && (data.tier == GOOD || data.tier == EPIC)) {
				var sparkleEmitter:SparkleEmitter = new SparkleEmitter(data.tier == EPIC ? 1 : 0.5, plaque.x, plaque.y, plaque.width, plaque.height, plaque);
				add(sparkleEmitter);
			}

			num++;
		}
		lastPage = Math.floor((num - 1) / plaquesPerShelf / shelvesPerPage);

		overlay = new FlxSprite(FlxG.width).loadGraphic(Paths.image('ui/menus/achievements/overlay'));
		overlay.scrollFactor.set();
		add(overlay);

		achievementName = new FlxText(FlxG.width, 0, overlayWidth - 50, '', 48);
		achievementName.scrollFactor.set();
		add(achievementName);

		achievementDescription = new FlxText(FlxG.width, 0, overlayWidth - 50, '', 32);
		achievementDescription.scrollFactor.set();
		add(achievementDescription);

		achievementProgress = new AchievementProgressBar();
		achievementProgress.setPosition(FlxG.width, 480);
		achievementProgress.scrollFactor.set();
		add(achievementProgress);

		exitButton = new SuffIconButton(20 + ScreenSafeArea.X, 20, 'buttons/exit', null, 2);
		exitButton.y = -exitButton.height;
		exitButton.scrollFactor.set();
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		resetButton = new SuffButton(20, 20, Language.getPhrase('achievementsMenu.resetProgress'), null, null, overlayWidth - 40, 100);
		resetButton.x = FlxG.width - overlayWidth + 20;
		resetButton.y = FlxG.height - resetButton.height - 40;
		resetButton.btnOutlineColor = resetButton.btnOutlineColorHovered = resetButton.btnOutlineColorClicked = resetButton.btnTextColor = resetButton.btnTextColorHovered = resetButton.btnTextColorClicked = 0xFFFFFFFF;
		resetButton.btnOutlineColorDisabled = resetButton.btnTextColorDisabled = 0xFF404040;
		resetButton.btnBGColor = resetButton.btnBGColorHovered = resetButton.btnBGColorClicked = resetButton.btnBGColorDisabled = 0xFF000000;
		resetButton.scrollFactor.set();
		resetButton.visible = false;
		add(resetButton);

		upButton = new SuffButton(20, 20, null, Paths.image('ui/menus/achievements/arrow'), Paths.image('ui/menus/achievements/arrowHovered'), 190, 100,
			false);
		upButton.x = ((FlxG.width - overlayWidth) - upButton.width) / 2;
		upButton.y = 20;
		upButton.scrollFactor.set();
		upButton.hoverSound = '';
		upButton.onClick = function() {
			changePage(-1);
		};
		add(upButton);
		upButton.visible = false;

		downButton = new SuffButton(20, 20, null, Paths.image('ui/menus/achievements/arrow'), Paths.image('ui/menus/achievements/arrowHovered'), 190, 100,
			false);
		downButton.x = ((FlxG.width - overlayWidth) - downButton.width) / 2;
		downButton.y = FlxG.height - downButton.height - 20;
		downButton.flipY = true;
		downButton.scrollFactor.set();
		downButton.hoverSound = '';
		downButton.onClick = function() {
			changePage(1);
		};
		add(downButton);
		downButton.visible = false;

		SuffState.playMusic('achievements');

		var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		black.scrollFactor.set();
		add(black);
		FlxTween.tween(black, {alpha: 0.75}, FlxG.sound.music.loopTime * 0.001, {
			onComplete: function(_) {
				black.destroy();
				showUI();
			}
		});

		instance = this;
	}

	function changePage(delta:Int = 0) {
		if (curPage + delta < 0 || curPage + delta > lastPage)
			return;
		if (delta != 0)
			SuffState.playUISound(Paths.sound('ui/pageChange'));
		curPage += delta;
		cameraPosOffset.y = -curPage * FlxG.height;
		upButton.visible = curPage > 0;
		downButton.visible = curPage < lastPage;
	}

	public function lockPlaque(id:String) {
		var plaque = plaques.members[Achievements.achievementIDs.indexOf(id)];
		plaque.locked = true;
	}

	function castSpotlight(target:AchievementPlaque) {
		if (!enableInput)
			return;
		spotlight.y = target.y - 85;
		spotlight.setGraphicSize(Std.int(target.width * 1.25), Std.int(Math.abs(spotlight.y - (target.y + target.height)) + 48));
		spotlight.updateHitbox();
		spotlight.x = target.x + (target.width - spotlight.width) / 2;
		spotlight.scale.x = 0.5;
		spotlight.visible = true;

		FlxTween.cancelTweensOf(spotlight, ['scale.x']);
		if (!Preferences.data.enablePhotosensitiveMode)
			FlxFlicker.flicker(spotlight, 0.25, 1 / 30, true, true);
		FlxTween.tween(spotlight, {'scale.x': 1}, 0.25, {
			ease: FlxEase.cubeOut
		});
	}

	public function changeAchievementText(?data:AchievementData, ?progress:Array<Dynamic>) {
		if (!enableInput)
			return;
		achievementName.x = FlxG.width;
		achievementDescription.x = FlxG.width;
		if (data != null) {
			achievementName.text = Language.getPhrase('achievement.${data.id}.name');
			achievementDescription.text = Language.getPhrase('achievement.${data.id}.description');
			if (Achievements.isLocked(data.id)) {
				if (data.hideName)
					achievementName.text = Utilities.replaceWithSubstr(achievementName.text, '?');
				if (data.hideDescription)
					achievementDescription.text = Utilities.replaceWithSubstr(achievementDescription.text, '?');
			}
		} else {
			achievementName.text = Language.getPhrase('achievementsMenu.title');
			achievementDescription.text = Language.getPhrase('achievementsMenu.description');
		}
		achievementName.updateHitbox();
		achievementDescription.updateHitbox();
		FlxTween.cancelTweensOf(achievementName);
		FlxTween.cancelTweensOf(achievementDescription);
		FlxTween.tween(achievementName, {x: (FlxG.width - overlayWidth) + (overlayWidth - achievementName.width) / 2}, 1, {
			ease: FlxEase.quintOut
		});
		FlxTween.tween(achievementDescription, {x: (FlxG.width - overlayWidth) + (overlayWidth - achievementDescription.width) / 2}, 1, {
			ease: FlxEase.quintOut,
			startDelay: 0.25
		});

		achievementName.y = ((FlxG.height - resetButton.height - 40) - (achievementName.height + achievementDescription.height)) / 2;
		achievementDescription.y = achievementName.y + achievementName.height;

		resetButton.visible = false;

		if (data == null || progress == null)
			return;

		resetButton.onClick = function() {
			openSubState(new ResetAchievementPrompt(data.id));
		};

		resetButton.visible = true;
		if (data.resettable != false) {
			switch (data.type) {
				case BOOLEAN:
					resetButton.disabled = !progress[0];
				case NUMBER:
					resetButton.disabled = progress[0] <= 0;
				case LIST:
					resetButton.disabled = progress.length <= 0;
			}
		} else {
			resetButton.disabled = true;
		}

		achievementProgress.reloadProgress(data, progress);
		achievementProgress.x = (FlxG.width - overlayWidth) + (overlayWidth - achievementProgress.width) / 2;

		achievementName.y = ((FlxG.height - resetButton.height - 40) - (achievementName.height + achievementDescription.height + achievementProgress.height + 20)) / 2;
		achievementDescription.y = achievementName.y + achievementName.height;
		achievementProgress.y = achievementDescription.y + achievementDescription.height + 20;
	}

	function showUI() {
		if (!Preferences.data.enablePhotosensitiveMode)
			FlxG.camera.flash(0xFFFFFFFF, 0.5);
		FlxTween.tween(exitButton, {y: 20 + ScreenSafeArea.Y}, 1, {
			ease: FlxEase.backOut
		});
		FlxTween.tween(overlay, {x: FlxG.width - overlay.width}, 0.75, {
			ease: FlxEase.quintOut
		});
		cameraPosOffset.x = -overlay.width / 2;
		enableInput = true;
		changePage();
		changeAchievementText();
	}

	function exitMenu() {
		if (!enableInput)
			return;
		enableInput = true;
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}

	var cameraPos:FlxPoint = new FlxPoint(FlxG.width / 2, FlxG.height / 2);
	var cameraPosOffset:FlxPoint = new FlxPoint(0, 0);
	var cameraPosLerped:FlxObject = new FlxObject(FlxG.width / 2, FlxG.height / 2);

	var what:Int = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		#if FLX_ACCELEROMETER
		if (FlxG.accelerometer.isSupported) {
			cameraPos.x = FlxG.width / 2 + (FlxG.accelerometer.x) * 64;
			cameraPos.y = FlxG.height / 2 + (FlxG.accelerometer.y) * 32;
		} else #end {
			cameraPos.x = FlxG.width / 2 + (FlxG.mouse.getScreenPosition().x - FlxG.width / 2) / 32;
			cameraPos.y = FlxG.height / 2 + (FlxG.mouse.getScreenPosition().y - FlxG.height / 2) / 16;
		}

		cameraPosLerped.x = FlxMath.lerp(cameraPosLerped.x, cameraPos.x - cameraPosOffset.x, elapsed * 8);
		cameraPosLerped.y = FlxMath.lerp(cameraPosLerped.y, cameraPos.y - cameraPosOffset.y, elapsed * 8);

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
		if (Controls.justPressed('up')) {
			changePage(-1);
		} else if (Controls.justPressed('down')) {
			changePage(1);
		}
		if (FlxG.mouse.wheel != 0) {
			changePage(-(FlxMath.signOf(FlxG.mouse.wheel)));
		}
	}
}
