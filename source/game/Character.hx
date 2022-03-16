package game;

import game.CharacterPart;
import options.Options;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

/**
	This `Character.hx` is meant for allowing characters to use more than one spritesheet.
	This should help optimize characters such as Girlfriend with her stupidly large spritesheet.
	This is not intended for Shaggy/Matt type shit, This is for optimization purposes.

	@param X             The X Position of the Character
	@param Y             The Y Position of the Character
	@param Character     The character itself lol
*/
class Character extends FlxTypedGroup<CharacterPart>
{
	public var curCharacter:String = 'bf';
	public var healthIcon:String = 'bf';
	public var healthColor:Array<Int> = [0, 0, 0];

	public var json:CharacterData = null;

	public var isPlayer:Bool = false;

	public var cameraPosition:Array<Int> = [0, 0];

	override public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;

		loadCharacter(x, y, character);
	}

	public function loadCharacter(x, y, ?character:String = 'bf')
	{
		for(char in members)
		{
			remove(char);
			char.kill();
			char.destroy();
		}

		clear();

		if(character != "")
		{
			json = Paths.parseJson('characters/$character/config');

			var characters:Array<String> = []; 
            if(json.characters != null)
                characters = json.characters;
            else
                characters = [character];

			healthIcon = json.healthicon;
			healthColor = json.healthbar_colors;

			for(char in characters)
			{
				var swagChar:CharacterPart = new CharacterPart(x, y, char, isPlayer);
				add(swagChar);
			}

			cameraPosition = json.camera_position;
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		for(char in members)
		{
			char.playAnim(AnimName, Force, Reversed, Frame);
		}
	}

	public function dance()
	{
		for(char in members)
		{
			char.dance();
		}
	}
}
