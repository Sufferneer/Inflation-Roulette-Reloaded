package states;

import backend.typedefs.LanguageMetadata;
import objects.particles.Explosion;
import states.WarningState;
import ui.objects.GitHubButton;
import ui.objects.SuffIconButton;
import ui.objects.SuffTextButton;
import tjson.TJSON as Json;
import substates.GenericPrompt;
import ui.objects.SuffScrollBar;

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
	var scrollBar:SuffScrollBar;
	var languageButtons:FlxTypedSpriteGroup<SuffTextButton> = new FlxTypedSpriteGroup<SuffTextButton>();
	var contributorText:FlxSpriteGroup = new FlxSpriteGroup();
	var languages:Array<String> = [];
	var languageMetadataList:Array<LanguageMetadata> = [];

	var curSelecting:Int = 0;
	var curSelected:Int = 0;
	var exiting:Bool = false;

	var bgOverlayScale:FlxPoint;

	public override function create() {
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		add(bg);

		bgOverlay = new FlxSprite().loadGraphic(Paths.getImage('ui/menus/language/bgOverlay'));
		bgOverlay.alpha = 0.2;
		bgOverlay.visible = false;
		bgOverlay.antialiasing = !Preferences.data.enableForcedAliasing;
		bgOverlay.setGraphicSize(FlxG.width, FlxG.height);
		bgOverlayScale = FlxPoint.get(FlxG.width / bgOverlay.width, FlxG.height / bgOverlay.height);
		bgOverlay.updateHitbox();
		bgOverlay.screenCenter();
		add(bgOverlay);

		ajuniga = new FlxSprite().loadGraphic(Paths.getImage('ui/menus/language/ajuniga'));
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
		selectorLeft.font = Paths.getFont('default', false);
		selectorLeft.x = -selectorLeft.width;

		selectorRight = new FlxText(0, 0, 0, '<', 48);
		selectorRight.font = Paths.getFont('default', false);
		selectorRight.x = FlxG.width;

		selectorLeft.color = selectorRight.color = textColor;
		selectedLine = new FlxSprite(0, 0).makeGraphic(1, 3, textColor);
		add(selectedLine);
		
		add(contributorText);

		languages = Utilities.textFileToArray('lang/languageList.txt');
		languages.unshift(Language.defaultLanguage);
		/*
		for (lang in languages.copy()) {
			for (i in 0...3) {
				languages.push(lang);
			}
		}
		 */
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
		var padding:Float = 32;
		for (num => item in languages) {
			var metadataJson = Paths.getTextFromFile('lang/$item/metadata.json');
			var metadata:LanguageMetadata = cast Json.parse(metadataJson);
			languageMetadataList.push(metadata);

			var langFontPath = Paths.getPath('lang/$item/fonts/default_$item.ttf');
			if (!Paths.fileExists(langFontPath)) {
				langFontPath = Paths.getFont('default');
			}
			var btnName = '${metadata.name} (${metadata.locale})';
			if (metadata.locale == null || metadata.locale == '')
				btnName = '${metadata.name}';
			var btn = new SuffTextButton(0, (64 + padding) * num, btnName, 48, langFontPath);
			btn.btnTextColor = btn.btnTextColorHovered = btn.btnTextColorClicked = textColor;
			btn.x = num % 2 == 0 ? -btn.width - 100 : FlxG.width + 100;
			if (btn.width > maxWidth)
				maxWidth = btn.width;
			if (Preferences.data.language == item) {
				curSelecting = curSelected = num;
			}
			btn.onHover = function() {
				curSelecting = num;
				// regenerateContributorsList(item, metadata.contributors);
			};
			btn.onClick = function() {
				if (Preferences.data.language != item) {
					Preferences.data.language = item;
					curSelected = num;
					Language.initialize();
					Preferences.savePrefs();
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					reloadText();
					regenerateContributorsList(item, metadata.contributors);
					if (Main.debugText != null) {
						Main.debugText.reloadFont();
					}
				} else {
					SuffState.playUISound(Paths.getSound('ui/invalid'));
				}
			}
			languageButtons.add(btn);
		}
		languageOverlay = new FlxSprite(0, FlxG.height).makeGraphic(Std.int(maxWidth + 64 + selectorLeft.width + selectorRight.width), FlxG.height, textColor);
		languageOverlay.screenCenter(X);
		languageOverlay.alpha = 0.25;
		add(languageOverlay);
		if (languageButtons.height <= FlxG.height - 64 - ScreenSafeArea.Y * 2)
			languageButtons.screenCenter(Y);
		else {
			languageButtons.y = 32 + ScreenSafeArea.Y;
			scrollBar = new SuffScrollBar(languageOverlay.x + languageOverlay.width, 0, function(percent:Float) {
				languageButtons.y = FlxMath.lerp(32 + ScreenSafeArea.Y, FlxG.height - languageButtons.height - 32 - ScreenSafeArea.Y, percent);
			}, 16, languageButtons.height + (32 + ScreenSafeArea.Y) * 2);
			scrollBar.visible = false;
			scrollBar.color = FlxColor.interpolate(textColor, leBGColor, 0.25);
			add(scrollBar);
		}
		add(languageButtons);

		add(selectorLeft);
		add(selectorRight);

		title = new FlxText(0, 64 + ScreenSafeArea.Y, (FlxG.width - languageOverlay.width) / 2 - 64 - ScreenSafeArea.X, Language.getPhrase('languageMenu.title'));
		title.setFormat(Paths.getFont('default'), 48, textColor);
		title.x = -title.width;
		add(title);

		var leProgress = (Language.getCompletionProgress(Preferences.data.language) * 100) + '%';
		progress = new SuffTextButton(0, title.y + title.height + 16, Language.getPhrase('languageMenu.completion', [leProgress]), 32, FlxPoint.get(0, 0));
		progress.btnTextFontPath = Paths.getFont('small');
		#if _ALLOW_FILE_CREATION
		progress.onClick = function() {
			if (!Language.exportUnmatchingKeys())
				return;
			openSubState(new GenericPrompt(Language.getPhrase('languageMenu.exportedUnmatchedKeys', ['exports/lang/${Preferences.data.language}_UNMATCHING.json']), 1080));
		};
		#end
		progress.btnTextColor = progress.btnTextColorHovered = progress.btnTextColorClicked = progress.btnTextColorDisabled = textColor;
		progress.x = -progress.width;
		progress.color = textColor;
		add(progress);

		description = new FlxText(0, progress.y + progress.height + 16, title.width, Language.getPhrase('languageMenu.description'));
		description.setFormat(Paths.getFont('small'), 32, textColor);
		description.x = -description.width;
		add(description);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
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

		if ((!initialized || Preferences.data.alwaysPlayMenuAnims) && !atWarningState) {
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

		reloadText();

		super.create();
	}
	
	function reloadText() {
		title.font = Paths.getFont('default');
		title.text = Language.getPhrase('languageMenu.title');

		progress.y = title.y + title.height + 16;
		progress.btnTextFontPath = Paths.getFont('small');
		var leProgress = (Language.getCompletionProgress(Preferences.data.language) * 100) + '%';
		progress.btnTextTxt = Language.getPhrase('languageMenu.completion', [leProgress]);
		progress.btnText.updateHitbox();
		progress.btnText.setPosition(progress.btnBG.x, progress.btnBG.y);
		progress.btnBG.resize(progress.btnText.width, progress.btnText.height);
		progress.visible = (Preferences.data.language != Language.defaultLanguage);

		description.font = Paths.getFont('small');
		description.text = Language.getPhrase('languageMenu.description');
		description.y = progress.y + progress.height + 16;

		WindowUtil.setTitle(Language.getPhrase('languageMenu.windowDisplay'));
	}

	final duration:Float = Math.PI;
	var tick:Float = 0;
	var started:Bool = false;
	var radius:Float = 200;

	function regenerateContributorsList(id:String, contributors:Array<String>) {
		contributorText.clear();
		if (id == Language.defaultLanguage)
			return;
		if (contributors == null || contributors.length <= 0)
			contributors = ['Unknown'];
		for (num => contributor in contributors) {
			var text:FlxText = new FlxText(0, 0, 0, contributor, 32);
			text.color = textColor;
			var langFont = Paths.getPath('lang/$id/fonts/small_$id.ttf');
			if (Paths.fileExists(langFont))
				text.font = langFont;
			else
				text.font = Paths.getFont('small');
			text.x = -text.width;
			text.y = FlxG.height - 32 - 32 * (contributors.length - num) - ScreenSafeArea.Y;
			FlxTween.tween(text, {x: 32 + ScreenSafeArea.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0.25 + 0.125 * num
			});
			contributorText.add(text);
		}
		var titleText:FlxText = new FlxText(0, 0, Language.getPhrase('languageMenu.contributors'), 32);
		titleText.color = textColor;
		titleText.x = -titleText.width;
		titleText.y = FlxG.height - titleText.height - 32 - 32 * contributors.length - ScreenSafeArea.Y;
		FlxTween.tween(titleText, {x: 32 + ScreenSafeArea.X}, 0.75, {
			ease: FlxEase.quintOut
		});
		contributorText.add(titleText);
	}

	public override function update(elapsed:Float) {
		if (tick < 0) {
			tick += elapsed;
			ajuniga.x = originalAjunigaPosition.x + Math.cos(tick * 2) * radius;
			ajuniga.y = originalAjunigaPosition.y + Math.sin(tick * 2) * (radius / FlxG.width * FlxG.height); // respect aspect ratio
			ajuniga.scale.x = ajuniga.scale.y = Math.pow(6, tick); // exponential growth
			ajuniga.angle = tick * Constants.TO_DEGREES;
		} else {
			transition();
			ajuniga.angle = Math.sin(this.elapsedTime) * 2;
		}

		bgOverlay.scale.x = bgOverlayScale.x + Math.pow(Math.sin(this.elapsedTime / Math.PI), 2) * 2;
		bgOverlay.scale.y = bgOverlayScale.y + Math.pow(Math.sin(this.elapsedTime / Math.PI * 0.75), 2) * 1.5;

		var btn = languageButtons.members[curSelecting];
		var btnSelected = languageButtons.members[curSelected];
		selectorLeft.y = selectorRight.y = btn.y + (btn.height - selectorLeft.height) / 2;
		selectorLeft.x = btn.x - selectorLeft.width - 8;
		selectorRight.x = btn.x + btn.width + 8;
		if (selectedLine != null && btnSelected != null) {
			selectedLine.x = btnSelected.x + btnSelected.width / 2;
			selectedLine.scale.x = btnSelected.width;
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
		if (scrollBar != null)
			scrollBar.visible = true;
		ajuniga.loadGraphic(Paths.getImage('ui/menus/language/ajunigaBlended'));
		ajuniga.angle = 0;
		exitButton.visible = githubButton.visible = true;

		regenerateContributorsList(languages[curSelected], languageMetadataList[curSelected].contributors);

		if (!instant) {
			FlxTween.tween(languageOverlay, {y: 0}, 0.5, {
				ease: FlxEase.quintOut,
				onComplete: function(_) {
					for (num => btn in languageButtons.members) {
						FlxTween.tween(btn, {x: (FlxG.width - btn.width) / 2}, 0.75, {
							ease: FlxEase.quintOut,
							startDelay: 1 / languageButtons.members.length * num
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

			FlxTween.tween(title, {x: 32 + ScreenSafeArea.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0
			});
			FlxTween.tween(progress, {x: 32 + ScreenSafeArea.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0.25
			});
			FlxTween.tween(description, {x: 32 + ScreenSafeArea.X}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0.5
			});

			var explod:Explosion = new Explosion(0, 0, 8);
			explod.screenCenter();
			add(explod);
		} else {
			languageOverlay.y = 0;
			for (num => btn in languageButtons.members) {
				btn.x = (FlxG.width - btn.width) / 2;
			}
			ajuniga.setPosition(FlxG.width * 0.6, FlxG.height * 0.4);
			ajuniga.scale.set(1.5, 1.5);
			title.x = description.x = progress.x = 32 + ScreenSafeArea.X;
		}
		if (!atWarningState)
			SuffState.playMusic('language');
	}
}
