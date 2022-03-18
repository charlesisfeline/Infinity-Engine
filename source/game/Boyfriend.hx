package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for(char in members)
		{
			if (!char.debugMode)
			{
				if (char.animation.curAnim.name.startsWith('sing'))
				{
					char.holdTimer += elapsed;
				}
				else
					char.holdTimer = 0;

				if (char.animation.curAnim.name.endsWith('miss') && char.animation.curAnim.finished && !char.debugMode)
				{
					char.playAnim('idle', true, false, 10);
				}

				/*if (char.animation.curAnim.name == 'firstDeath' && char.animation.curAnim.finished)
				{
					char.playAnim('deathLoop');
				}*/
			}
		}
	}
}
