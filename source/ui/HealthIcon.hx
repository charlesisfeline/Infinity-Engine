package ui;

import flixel.FlxSprite;
import options.OptionsHandler;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;

		changeIcon(char);
		scrollFactor.set();
	}

	public function changeIcon(char:String = 'bf')
	{
		loadGraphic(Paths.image('icons/' + char));
		loadGraphic(Paths.image('icons/' + char), true, Math.floor(height), Math.floor(height));

		if (char.endsWith('-pixel') || char.startsWith('senpai') || char.startsWith('spirit'))
			antialiasing = false;
		else
			antialiasing = Options.getData('anti-aliasing');

		animation.add(char, [0, 1, 2], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
