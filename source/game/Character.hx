package game;

import options.Options;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

typedef CharAnimationData = {
	var offsets:Array<Float>;
	var loop:Bool;
	var anim:String;
	var fps:Int;
	var name:String;
	var indices:Array<Int>;
};

typedef CharacterData = {
	var animations:Array<CharAnimationData>;
	var no_antialiasing:Bool;
	var position:Array<Float>;
	var healthicon:String;
	var flip_x:Bool;
	var healthbar_colors:Array<Int>;
	var camera_position:Array<Int>;
	var sing_duration:Float;
	var scale:Float;
	var packer_atlas:Bool;
};

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var danceLeftRight:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var singDuration:Float = 6.1;
	public var healthColor:Array<Int> = [0, 0, 0];
	public var healthIcon:String = 'bf';

	public var cameraPosition:Array<Int> = [0, 0];

	public var holdTimer:Float = 0;

	public var json:CharacterData = null;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		this.isPlayer = isPlayer;

		loadCharacter(character);
	}

	public function loadCharacter(?character:String = "bf")
	{
		curCharacter = character;

		switch (curCharacter)
		{
			default:
				json = Paths.parseJson('characters/$curCharacter/config', true);

				if(json.packer_atlas)
					frames = Paths.getPackerAtlas('characters/$curCharacter/assets', null, true);
				else
					frames = Paths.getSparrowAtlas('characters/$curCharacter/assets', null, true);
				
				for(anim in json.animations)
				{
					animation.addByPrefix(anim.anim, anim.name, anim.fps);
					addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}

				danceLeftRight = animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null;

				if(Options.getData('anti-aliasing') == true)
					antialiasing = !json.no_antialiasing;
				else
					antialiasing = false;

				x += json.position[0];
				y += json.position[1];

				healthColor = json.healthbar_colors;
				singDuration = json.sing_duration;

				cameraPosition = json.camera_position;

				scale.set(json.scale, json.scale);
				updateHitbox();

				//dance();

			case 'your-hardcoded-character': // THIS IS HERE IF YOU WANNA HARDCODE FOR SOME REASON LOL
				frames = Paths.getSparrowAtlas('characters/$curCharacter/assets', null, true);
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				//playAnim('idle');
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF/SPOOKY DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			if(danceLeftRight)
				if (!animation.curAnim.name.startsWith('hair'))
				{
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			else
				playAnim('idle');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
