package ui;

import options.OptionsHandler;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef MenuCharacterData = {
	var idle_anim:Array<Dynamic>;
	var confirm_anim:Array<Dynamic>;
	var scale:Float;
	var flip_x:Bool;
	var position:Array<Float>;
};

class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var json:MenuCharacterData;

	public var ogPos:Array<Float> = [0, 0];

	public function new(x:Float, y:Float, character:String = 'bf')
	{
		super(x, y);
		ogPos = [x, y];

		loadCharacter(character, true);
	}

	public function loadCharacter(?character:String = "bf", ?force:Bool = false)
	{
		if(this.character != character || force)
		{
			this.character = character;
			
			if(character != "")
			{
				visible = true;

				json = Paths.parseJson('images/weekcharacters/$character/config');

				if(json == null)
					json = Paths.parseJson('images/weekcharacters/dad/config');

				frames = Paths.getSparrowAtlas('weekcharacters/$character/assets');

				antialiasing = Options.getData('anti-aliasing');
				/*switch (weekCharacterThing.character)
				{
					case 'dad':
						weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
						weekCharacterThing.updateHitbox();

					case 'bf':
						weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
						weekCharacterThing.updateHitbox();
						weekCharacterThing.x -= 80;
					case 'gf':
						weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
						weekCharacterThing.updateHitbox();
					case 'pico':
						weekCharacterThing.flipX = true;
					case 'parents-christmas':
						weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
						weekCharacterThing.updateHitbox();
				}*/

				animation.addByPrefix('idle', json.idle_anim[0], json.idle_anim[1]);
				animation.addByPrefix('confirm', json.confirm_anim[0], json.confirm_anim[1], false);
				// Parent Christmas Idle

				scale.set(json.scale, json.scale);
				updateHitbox();

				playAnim('idle');

				flipX = json.flip_x;

				setPosition(ogPos[0], ogPos[1]);
				x += json.position[0];
				y += json.position[1];
			}
			else
				visible = false;
		}
	}

	public function playAnim(anim:String, force:Bool = false)
	{
		animation.play(anim);

		switch(anim)
		{
			case 'idle':
				offset.set(json.idle_anim[2][0], json.idle_anim[2][1]);
			case 'confirm':
				offset.set(json.confirm_anim[2][0], json.confirm_anim[2][1]);
			default:
				offset.set(0, 0);
		}
	}
}
