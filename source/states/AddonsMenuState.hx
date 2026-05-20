package states;

import backend.Addons;
import backend.typedefs.AddonMetadata;
import states.MainMenuState;
import ui.objects.AddonMenuItem;
import ui.objects.GitHubButton;
import ui.objects.SuffIconButton;
import tjson.TJSON as Json;
import ui.objects.SuffScrollBar;

class AddonsMenuState extends SuffState {
	var bg:FlxSprite;
	var icons:FlxBackdrop;
	var modBG:FlxSprite;
	var modItems:FlxTypedSpriteGroup<AddonMenuItem> = new FlxTypedSpriteGroup<AddonMenuItem>();
	var modItemsScrollBar:SuffScrollBar;

	var modBannerBG:FlxSprite;
	var modBanner:FlxSprite;
	var modBannerVignette:FlxSprite;

	var modMetadataItems:FlxSpriteGroup = new FlxSpriteGroup();
	var modMetadataItemsScrollBar:SuffScrollBar;

	var noAddonsInstalled:Bool = false;

	public static final padding:Int = 20;
	public static final itemCount:Int = 5;

	final scrollBarWidth:Int = 30;

	override function create() {
		super.create();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.alpha = 0.5;
		add(bg);

		icons = new FlxBackdrop(Paths.image('ui/menus/addons/bg'));
		icons.scale.set(2, 2);
		icons.updateHitbox();
		icons.velocity.set(-40, -40);
		icons.alpha = 0.5;
		add(icons);

		var exitButton = new SuffIconButton(20, 20 + ScreenSafeZone.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeZone.X;
		exitButton.onClick = function() {
			backToMainMenu();
		};

		SuffState.playMusic('options');

		var leAddons = Addons.getGlobalAddons();

		if (leAddons.length <= 0) {
			noAddonsInstalled = true;

			var noModsDetected:FlxText = new FlxText(0, 0, 0, Language.getPhrase('addonsMenu.noAddonsDetected.title'));
			noModsDetected.setFormat(Paths.font('default'), 64);

			var noModsDetectedDesc:FlxText = new FlxText(0, 0, Std.int(noModsDetected.width * 1.5), Language.getPhrase('addonsMenu.noAddonsDetected.content'));
			noModsDetectedDesc.setFormat(Paths.font('default'), 32, 0xFFFFFFFF, CENTER);

			noModsDetected.screenCenter(X);
			noModsDetected.y = (FlxG.height - (noModsDetected.height + noModsDetectedDesc.height)) / 2;
			noModsDetectedDesc.screenCenter(X);
			noModsDetectedDesc.y = (FlxG.height - (noModsDetected.height + noModsDetectedDesc.height)) / 2 + noModsDetected.height;
			add(noModsDetected);
			add(noModsDetectedDesc);

			var button:GitHubButton = new GitHubButton(0, 0, 'issues');
			button.screenCenter(X);
			button.y = noModsDetectedDesc.y + noModsDetectedDesc.height;
			add(button);

			bg.color = 0xFF404040;
			add(exitButton);

			return;
		}

		modBG = new FlxSprite(padding, 0).makeGraphic(Std.int(FlxG.width / 2 - padding - scrollBarWidth), Std.int(FlxG.height), 0xFF000000);
		modBG.alpha = 0.5;
		add(modBG);

		AddonMenuItem.defaultWidth = Std.int(modBG.width);
		AddonMenuItem.defaultHeight = Std.int(modBG.height / AddonsMenuState.itemCount);

		add(modItems);
		for (i in 0...leAddons.length) {
			var folder:String = leAddons[i];
			var leModData:AddonMetadata = cast Addons.getAddonMetadata(folder);

			var item:AddonMenuItem = new AddonMenuItem(modBG.x, modBG.y + AddonMenuItem.defaultHeight * i, folder, leModData);
			item.onClick = function() {
				changeDisplayedMetadata(folder, leModData);
			}
			modItems.add(item);
		}

		var modItemsScrollLimit:Float = 0;

		if (modItems.height > FlxG.height) {
			modItemsScrollLimit = modItems.height - FlxG.height;
		}

		modItemsScrollBar = new SuffScrollBar(modBG.x + modBG.width, modBG.y, function(percent:Float) {
			modItems.y = FlxMath.lerp(0, FlxG.height - modItems.height, percent);
		}, scrollBarWidth, modItems.height);
		modItemsScrollBar.visible = (modItems.height > FlxG.height);
		modItemsScrollBar.disabled = !modItemsScrollBar.visible;
		modItemsScrollBar.scrollWidth = modItemsScrollBar.mouseScrollWidth = [-FlxG.width / 2, 0];
		add(modItemsScrollBar);

		modBanner = new FlxSprite();

		modBannerVignette = new FlxSprite().loadGraphic(Paths.image('ui/menus/addons/bannerVignette'));
		modBannerVignette.alpha = 0.5;
		changeBanner('');

		modBannerBG = new FlxSprite();
		modBannerBG.makeGraphic(Std.int(modBanner.width), FlxG.height, 0xFF000000);
		modBannerBG.alpha = 0.5;
		modBannerBG.x = modBanner.x;
		modBannerBG.y = modBanner.y;
		add(modBannerBG);

		add(modMetadataItems);

		add(modBanner);
		add(modBannerVignette);

		modMetadataItemsScrollBar = new SuffScrollBar(0, 0, scrollBarWidth);
		modMetadataItemsScrollBar.mouseScrollWidth = [0, FlxG.width];
		add(modMetadataItemsScrollBar);

		if (leAddons.length > 0) {
			changeDisplayedMetadata(leAddons[0], modItems.members[0].addon);
		} else {
			changeDisplayedMetadata('', null);
		}

		add(exitButton);
	}

	function changeDisplayedMetadata(folder:String, addon:AddonMetadata = null) {
		changeBanner(folder);

		modMetadataItems.clear();

		if (addon == null)
			return;
		var modMetadataY:Float = 0;

		var modMetadataTitle = new FlxText(modBannerBG.x + 16, modMetadataY, modBannerBG.width - 32, addon.name, 48);
		modMetadataTitle.font = Paths.font('default', false);
		modMetadataItems.add(modMetadataTitle);
		modMetadataY += modMetadataTitle.height;
		var modMetadataDesc = new FlxText(modMetadataTitle.x, modMetadataY, modMetadataTitle.width, addon.description, 32);
		modMetadataDesc.font = Paths.font('default', false);
		modMetadataY += modMetadataDesc.height + 32;
		modMetadataItems.add(modMetadataDesc);
		var authorStr:String = '';
		var authors:Array<Array<String>> = addon.authors;
		for (i in 0...authors.length) {
			var name:String = authors[i][0];
			var role:String = authors[i][1];
			if (authorStr.length > 0)
				authorStr += '\n';
			authorStr += '$name - $role';
		}
		var modAuthorsText = new FlxText(modMetadataTitle.x, modMetadataY, modMetadataDesc.width, authorStr, 32);
		modAuthorsText.font = Paths.font('default', false);
		modMetadataItems.add(modAuthorsText);

		modMetadataItems.y = modBanner.y + modBanner.height;

		if (modMetadataItemsScrollBar != null) {
			modMetadataItemsScrollBar.x = modBannerBG.x - modMetadataItemsScrollBar.width;
			var bounds:Float = FlxG.height - (modBanner.y + modBanner.height);
			var valueToScroll:Float = modMetadataItems.height / bounds;
			if (valueToScroll > 1) {
				modMetadataItemsScrollBar.reloadDimensions(scrollBarWidth, valueToScroll * FlxG.height);
				modMetadataItemsScrollBar.disabled = false;
				modMetadataItemsScrollBar.visible = true;
			} else {
				modMetadataItemsScrollBar.disabled = true;
				modMetadataItemsScrollBar.visible = false;
			}
			modMetadataItemsScrollBar.scrollCallback = function(percent:Float) {
				modMetadataItems.y = FlxMath.lerp(modBanner.y + modBanner.height,  FlxG.height - modMetadataItems.height, percent);
			}
		}

		FlxTween.cancelTweensOf(bg, ['color']);
		FlxTween.color(bg, 1, bg.color, FlxColor.fromString(addon.color));
	}

	function changeBanner(folder:String) {
		var path:String = Paths.addons('$folder/metadata/banner.png');
		if (!FileSystem.exists(path)) {
			path = Paths.getImagePath('ui/menus/addons/defaultBanner');
		}
		var leImage = Paths.cacheBitmap(path);
		var leWidth:Float = Std.int(FlxG.width / 2 - padding - scrollBarWidth);
		modBanner.loadGraphic(leImage);
		modBanner.setGraphicSize(Std.int(leWidth), Std.int(leWidth / 16 * 9));
		modBanner.updateHitbox();

		modBannerVignette.setGraphicSize(Std.int(modBanner.width), Std.int(modBanner.height));
		modBannerVignette.updateHitbox();

		modBannerVignette.x = modBanner.x = FlxG.width - modBanner.width - padding;
		modBannerVignette.y = modBanner.y;
	}

	var modItemsScroll:Float = 0;
	var modItemsScrollLerped:Float = 0;

	var modMetadataItemsScroll:Float = 0;
	var modMetadataItemsScrollLerped:Float = 0;

	static final scrollLerpFactor:Float = 10;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			backToMainMenu();
		}

		if (noAddonsInstalled)
			return;
		/*
		if (FlxG.mouse.pressed) {
			if (modMetadataItemsScrollBar.visible && FlxG.mouse.x > FlxG.width / 2) {
				modMetadataItemsScroll = modMetadataItemsScroll + (FlxG.mouse.deltaScreenY) * (FlxG.height / modMetadataItemsScrollBar.height);
				boundModMetadataItemsY();
			} else if (modItemsScrollBar.visible && FlxG.mouse.x < FlxG.width / 2) {
				modItemsScroll = modItemsScroll + (FlxG.mouse.deltaScreenY) * (FlxG.height / modItemsScrollBar.height);
				boundModItemsY();
			}
		}

		modItemsScrollLerped = FlxMath.lerp(modItemsScrollLerped, modItemsScroll, elapsed * scrollLerpFactor);
		modItems.y = -modItemsScrollLerped;

		modMetadataItemsScrollLerped = FlxMath.lerp(modMetadataItemsScrollLerped, modMetadataItemsScroll, elapsed * scrollLerpFactor);
		modMetadataItems.y = modBanner.y + modBanner.height - modMetadataItemsScrollLerped;

		updateModMetadataItemsScrollBar();
		 */
	}

	function backToMainMenu() {
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}
}
