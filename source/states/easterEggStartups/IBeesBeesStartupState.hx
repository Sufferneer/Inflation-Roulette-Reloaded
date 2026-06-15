package states.easterEggStartups;

import flixel.group.FlxSpriteContainer;
import objects.particles.Explosion;

class IBeesBeesStartupState extends SuffState {
	var allowToSkip:Bool = true;
	var skipIntroTimer:FlxTimer;

	var bg:FlxBackdrop;
	final pizzaSize:FlxRect = new FlxRect(0, 0, 160, 120);
	var pizzas:FlxSpriteContainer = new FlxSpriteContainer();
	var shownPizzas:Array<Int> = [];

	override function create() {
		super.create();

		Window.setTitle(Constants.COPYRIGHT, 'Original Concept by Snowyboi');

		bg = new FlxBackdrop(Paths.image('ui/menus/easterEggStartups/ibeesbees/bg'));
		bg.color = 0xFFFFFFFF;
		bg.velocity.set(60, 60);
		add(bg);

		var bgWhat = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.1), Std.int(FlxG.height * 1.1), 0xFF000000);
		bgWhat.screenCenter();
		bgWhat.alpha = 0.75;
		add(bgWhat);

		var bgMask = new FlxSprite().loadGraphic(Paths.image('ui/menus/easterEggStartups/mask'));
		bgMask.scale.set(2, 2);
		add(bgMask);

		add(pizzas);
		var _width = Math.ceil(FlxG.width / pizzaSize.width);
		var _height = Math.ceil(FlxG.height / pizzaSize.height);
		for (w in 0..._width) {
			for (h in 0..._height) {
				var pizza = new FlxSprite(w * pizzaSize.width, h * pizzaSize.height).loadGraphic(Paths.image('ui/menus/easterEggStartups/ibeesbees/pizza'));
				pizza.setGraphicSize(Std.int(pizzaSize.width), Std.int(pizzaSize.height));
				pizza.updateHitbox();
				pizza.alpha = (w + h) % 2 * 0.2 + 0.4;
				pizza.visible = false;
				pizzas.add(pizza);
			}
		}

		new FlxTimer().start(1, function(_) {
			new FlxTimer().start(0.1, function(_) {
				showPizza();
			}, _width * _height);
		});

		skipIntroTimer = new FlxTimer().start(1 + (_width * _height + 5) * 0.1, function(_) {
			skipIntro();
		});
	}

	function showPizza() {
		if (!allowToSkip)
			return;

		var randomIndex = FlxG.random.int(0, pizzas.members.length - 1, shownPizzas);
		var leMember = pizzas.members[randomIndex];
		leMember.visible = true;

		SuffState.playUISound(Paths.sound('ui/transition/pop_1'), 1, 2.25);
		shownPizzas.push(randomIndex);
	}

	function skipIntro() {
		if (!allowToSkip)
			return;

		for (num => pizza in pizzas.members) {
			pizza.visible = true;
			new FlxTimer().start(FlxG.random.int(0, 6) * 0.25, function(_) {
				pizza.acceleration.y = FlxG.height * 4;
			});
		}

		FlxG.camera.fade(0xFF000000, 2.5, false, function() {
			FlxTransitionableState.skipNextTransIn = true;
			SuffState.switchState(new MainMenuState());
		});

		allowToSkip = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit') || Controls.justPressed('shoot') || FlxG.mouse.justPressed) {
			skipIntroTimer.cancel();
			skipIntro();
		}
	}
}
