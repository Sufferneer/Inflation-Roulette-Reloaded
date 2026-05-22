package states;

import backend.typedefs.LanguageMetadata;
import objects.particles.Explosion;
import states.WarningState;
import ui.objects.GitHubButton;
import ui.objects.SuffIconButton;
import ui.objects.SuffTextButton;
import tjson.TJSON as Json;
import substates.GenericPrompt;

class LanguageSelectState extends SuffState {
	public static var initialized:Bool = false;
	public static var atWarningState:Bool = false;

	var bg:FlxSprite;
	var bgOverlay:FlxSprite;
	var selectorLeft:FlxText;
	var selectorRight:FlxText;
	var selectedLine:FlxSprite;
	var languageOverlay:FlxSprite;
	var ajuniga:FlxSprite;
	var originalAjunigaPosition:FlxPoint;
	var exitButton:SuffIconButton;
	var githubButton:GitHubButton;

	var leBGColor:FlxColor = 0xFFFDE871;
	var textColor:FlxColor = 0xFFDC7827;
	final leBGColorAlt:FlxColor = 0xFF000000;
	final textColorAlt:FlxColor = 0xFFFFFFFF;
	var title:FlxText;
	var description:FlxText;
	var progress:SuffTextButton;
	var languageButtons:FlxTypedContainer<SuffTextButton> = new FlxTypedContainer<SuffTextButton>();
	var contributorText:FlxSpriteGroup = new FlxSpriteGroup();
	var languages:Array<String> = [];
	var languageMetadataList:Array<LanguageMetadata> = [];

	var curSelecting:Int = 0;
	var curSelected:Int = 0;
	var exiting:Bool = false;

	var bgOverlayScale:FlxPoint;

	override function create() {
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		add(bg);

		bgOverlay = new FlxSprite().loadGraphic(Paths.image('ui/menus/language/bgOverlay'));
		bgOverlay.alpha = 0.2;
		bgOverlay.visible = false;
		bgOverlay.antialiasing = !Preferences.data.enableForcedAliasing;
		bgOverlay.setGraphicSize(FlxG.width, FlxG.height);
		bgOverlayScale = FlxPoint.get(FlxG.width / bgOverlay.width, FlxG.height / bgOverlay.height);
		bgOverlay.updateHitbox();
		bgOverlay.screenCenter();
		add(bgOverlay);

		ajuniga = new FlxSprite().loadGraphic(Paths.image('ui/menus/language/ajuniga'));
		ajuniga.screenCenter();
		originalAjunigaPosition = new FlxPoint(ajuniga.x, ajuniga.y);
		ajuniga.antialiasing = !Preferences.data.enableForcedAliasing;
		add(ajuniga);

		if (atWarningState) {
			leBGColor = leBGColorAlt;
			textColor = textColorAlt;
			bgOverlay.alpha = 0;
			ajuniga.alpha = 0;
		}

		selectorLeft = new FlxText(0, 0, 0, '>', 48);
		selectorLeft.font = Paths.font('default', false);
		selectorLeft.x = -selectorLeft.width;

		selectorRight = new FlxText(0, 0, 0, '<', 48);
		selectorRight.font = Paths.font('default', false);
		selectorRight.x = FlxG.width;

		selectorLeft.color = selectorRight.color = textColor;
		add(contributorText);

		languages = Utilities.textFileToArray('lang/languageList.txt');
		languages.unshift(Language.defaultLanguage);
		languages.sort(function(a:String, b:String):Int {
			a = a.toUpperCase();
			b = b.toUpperCase();
			if (a < b) {
				return -1;
			} else if (a > b) {
				return 1;
			} else {
				return 0;
			}
		}); // Sort languages alphabetically by their ID
		var maxWidth:Float = 0;
		var padding:Float = Math.max(32, 96 / languages.length);
		for (num => item in languages) {
			var metadataJson = Paths.getTextFromFile('lang/$item/metadata.json');
			var metadata:LanguageMetadata = cast Json.parse(metadataJson);
			languageMetadataList.push(metadata);

			var langFontPath = Paths.getPath('lang/$item/fonts/default_$item.ttf');
			if (!Paths.fileExists(langFontPath)) {
				langFontPath = Paths.font('default');
			}
			var btn = new SuffTextButton(32, (FlxG.height - (languages.length * 64 + (languages.length - 1) * padding)) / 2 + (64 + padding) * num,
				'${metadata.name} (${metadata.locale})', 48, langFontPath);
			btn.btnTextColor = textColor;
			btn.x = num % 2 == 0 ? -btn.width - 100 : FlxG.width + 100;
			if (btn.width > maxWidth)
				maxWidth = btn.width;
			if (Preferences.data.language == item) {
				curSelecting = curSelected = num;
				selectedLine = new FlxSprite(0, 0).makeGraphic(Std.int(btn.width), 3, textColor);
				add(selectedLine);
			}
			btn.onHover = function() {
				curSelecting = num;
				regenerateContributorsList(item, metadata.contributors);
			};
			btn.onClick = function() {
				if (Preferences.data.language != item) {
					Preferences.data.language = item;
					Language.initialize();
					Preferences.savePrefs();
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.resetState();
					if (Main.debugText != null) {
						Main.debugText.reloadFont();
					}
				} else {
					SuffState.playUISound(Paths.sound('ui/invalid'));
				}
			}
			languageButtons.add(btn);
		}
		languageOverlay = new FlxSprite(0, FlxG.height).makeGraphic(Std.int(maxWidth + 64 + selectorLeft.width + selectorRight.width), FlxG.height, textColor);
		languageOverlay.screenCenter(X);
		languageOverlay.alpha = 0.25;
		add(languageOverlay);
		add(languageButtons);

		add(selectorLeft);
		add(selectorRight);

		title = new FlxText(0, 64 + ScreenSafeZone.Y, (FlxG.width - languageOverlay.width) / 2 - 64, Language.getPhrase('languageMenu.title'));
		title.setFormat(Paths.font('default'), 48, textColor);
		title.x = -title.width;
		add(title);

		var leProgress = (Language.getCompletionProgress(Preferences.data.language) * 100) + '%';
		progress = new SuffTextButton(0, title.y + title.height + 16, Language.getPhrase('languageMenu.completion', [leProgress]), 32, FlxPoint.get(0, 0));
		progress.btnTextFontPath = Paths.font('small');
		var missingKeys = Language.logMissingKeys();
		progress.disabled = (missingKeys.length <= 0);
		progress.onClick = function() {
			openSubState(new GenericPrompt(missingKeys.join('\n'), 1080));
		};
		progress.btnTextColor = progress.btnTextColorHovered = progress.btnTextColorClicked = progress.btnTextColorDisabled = textColor;
		progress.x = -progress.width;
		progress.color = textColor;
		add(progress);

		description = new FlxText(0, progress.y + progress.height + 16, title.width, Language.getPhrase('languageMenu.description'));
		description.setFormat(Paths.font('small'), 32, textColor);
		description.x = -description.width;
		add(description);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeZone.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeZone.X;
		exitButton.btnTextColor = exitButton.btnTextColorHovered = exitButton.btnTextColorClicked = textColor;
		exitButton.btnOutlineColor = exitButton.btnOutlineColorHovered = exitButton.btnOutlineColorClicked = textColor;
		exitButton.btnBGColor = exitButton.btnBGColorHovered = exitButton.btnBGColorClicked = leBGColor;
		exitButton.visible = false;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		githubButton = new GitHubButton(exitButton.x, exitButton.y + exitButton.height + 20, 'issues');
		githubButton.visible = false;
		add(githubButton);

		if (!initialized && !atWarningState) {
			initialized = true;

			SuffState.playMusic('null');
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			tick = -duration;

			FlxTween.num(radius, 0, duration + 0.5, {
				ease: FlxEase.expoIn
			}, function(num:Float) {
				radius = num;
			});
		} else {
			transition(true);
		}

		super.create();
	}

	final duration:Float = Math.PI;
	var tick:Float = 0;
	var started:Bool = false;
	var radius:Float = 200;

	function regenerateContributorsList(id:String, contributors:Array<String>) {
		contributorText.clear();
		if (contributors == null || contributors.length <= 0)
			contributors = ['Unknown'];
		for (num => contributor in contributors) {
			var text:FlxText = new FlxText(0, 0, 0, contributor, 32);
			text.color = textColor;
			var langFont = Paths.getPath('lang/$id/fonts/small_$id.ttf');
			if (Paths.fileExists(langFont))
				text.font = langFont;
			else
				text.font = Paths.font('small');
			text.x = -text.width;
			text.y = FlxG.height - 32 - 32 * (contributors.length - num) - ScreenSafeZone.Y;
			FlxTween.tween(text, {x: 32 + ScreenSafeZone.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0.25 + 0.125 * num
			});
			contributorText.add(text);
		}
		var titleText:FlxText = new FlxText(0, 0, Language.getPhrase('languageMenu.contributors'), 48);
		titleText.color = textColor;
		titleText.x = -titleText.width;
		titleText.y = FlxG.height - titleText.height - 32 - 32 * contributors.length - ScreenSafeZone.Y;
		FlxTween.tween(titleText, {x: 32 + ScreenSafeZone.X}, 0.75, {
			ease: FlxEase.quintOut
		});
		contributorText.add(titleText);
	}

	override function update(elapsed:Float) {
		if (tick < 0) {
			tick += elapsed;
			ajuniga.x = originalAjunigaPosition.x + Math.cos(tick * 2) * radius;
			ajuniga.y = originalAjunigaPosition.y + Math.sin(tick * 2) * (radius / FlxG.width * FlxG.height); // respect aspect ratio
			ajuniga.scale.x = ajuniga.scale.y = Math.pow(6, tick); // exponential growth
			ajuniga.angle = tick * Constants.TO_DEGREES;
		} else {
			transition();
			ajuniga.angle = Math.sin(SuffState.timePassedOnState) * 2;
		}

		bgOverlay.scale.x = bgOverlayScale.x + Math.pow(Math.sin(SuffState.timePassedOnState / Math.PI), 2) * 2;
		bgOverlay.scale.y = bgOverlayScale.y + Math.pow(Math.sin(SuffState.timePassedOnState / Math.PI * 0.75), 2) * 1.5;

		var btn = languageButtons.members[curSelecting];
		var btnSelected = languageButtons.members[curSelected];
		selectorLeft.y = selectorRight.y = btn.y + (btn.height - selectorLeft.height) / 2;
		selectorLeft.x = btn.x - selectorLeft.width - 8;
		selectorRight.x = btn.x + btn.width + 8;
		if (selectedLine != null && btnSelected != null) {
			selectedLine.x = btnSelected.x;
			selectedLine.y = btnSelected.y + btnSelected.height - 7;
		}

		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
		if (FlxG.mouse.justPressed) {
			transition();
		}
	}

	function exitMenu() {
		if (exiting)
			return;
		exiting = true;
		// initialized = false;
		FlxTransitionableState.skipNextTransIn = atWarningState;
		FlxTransitionableState.skipNextTransOut = atWarningState;
		if (!atWarningState) {
			SuffState.playMusic('mainMenu');
			SuffState.switchState(new MainMenuState());
		} else {
			SuffState.switchState(new WarningState());
		}
	}

	function transition(instant:Bool = false) {
		if (started || exiting)
			return;
		tick = 0;

		started = true;

		bg.color = leBGColor;
		bgOverlay.visible = true;
		ajuniga.loadGraphic(Paths.image('ui/menus/language/ajunigaBlended'));
		ajuniga.angle = 0;
		exitButton.visible = githubButton.visible = true;

		regenerateContributorsList(languages[curSelected], languageMetadataList[curSelected].contributors);

		if (!instant) {
			FlxTween.tween(languageOverlay, {y: 0}, 0.5, {
				ease: FlxEase.quintOut,
				onComplete: function(_) {
					for (num => btn in languageButtons) {
						FlxTween.tween(btn, {x: (FlxG.width - btn.width) / 2}, 0.75, {
							ease: FlxEase.quintOut,
							startDelay: num * 0.1
						});
					}
				}
			});

			FlxTween.tween(ajuniga, {
				x: FlxG.width * 0.6,
				y: FlxG.height * 0.4,
				'scale.x': 1.5,
				'scale.y': 1.5
			}, 1, {
				ease: FlxEase.quintOut
			});

			FlxTween.tween(title, {x: 32 + ScreenSafeZone.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0
			});
			FlxTween.tween(progress, {x: 32 + ScreenSafeZone.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0.25
			});
			FlxTween.tween(description, {x: 32 + ScreenSafeZone.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0.5
			});

			var explod:Explosion = new Explosion(0, 0, 8);
			explod.screenCenter();
			add(explod);
		} else {
			languageOverlay.y = 0;
			for (num => btn in languageButtons) {
				btn.x = (FlxG.width - btn.width) / 2;
			}
			ajuniga.setPosition(FlxG.width * 0.6, FlxG.height * 0.4);
			ajuniga.scale.set(1.5, 1.5);
			title.x = description.x = progress.x = 32 + ScreenSafeZone.X;
		}
		if (!atWarningState)
			SuffState.playMusic('language');
	}
}
