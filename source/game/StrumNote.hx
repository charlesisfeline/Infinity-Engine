package game;

import states.PlayState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import options.OptionsHandler;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class StrumNote extends FlxSprite
{
	public var noteData:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;

	public function new(x:Float, y:Float, noteData:Int, ?noteskin:String = "default")
	{
		super(x, y);

        this.noteData = noteData;
		loadNoteSkin(noteskin);
	}

	public function loadNoteSkin(?noteskin:String = "default")
	{
		if(noteskin.endsWith("-pixel"))
		{
			loadGraphic(Paths.image('ui-skins/$noteskin/notes'), true, 17, 17);

            switch(Math.abs(noteData))
            {
                case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);		
                case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
                case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 24, false);		
                case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);		
            }

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			antialiasing = false;
		} else {
			frames = Paths.getSparrowAtlas('ui-skins/$noteskin/strums');

            switch(Math.abs(noteData))
            {
                case 0:
			        animation.addByPrefix('static', 'left static', 24, true);
                    animation.addByPrefix('pressed', 'left press', 24, false);
                    animation.addByPrefix('confirm', 'left confirm', 24, false);
                case 1:
			        animation.addByPrefix('static', 'down static', 24, true);
                    animation.addByPrefix('pressed', 'down press', 24, false);
                    animation.addByPrefix('confirm', 'down confirm', 24, false);
                case 2:
			        animation.addByPrefix('static', 'up static', 24, true);
                    animation.addByPrefix('pressed', 'up press', 24, false);
                    animation.addByPrefix('confirm', 'up confirm', 24, false);
                case 3:
			        animation.addByPrefix('static', 'right static', 24, true);
                    animation.addByPrefix('pressed', 'right press', 24, false);
                    animation.addByPrefix('confirm', 'right confirm', 24, false);
            }

			setGraphicSize(Std.int(width * 0.7));
			antialiasing = Options.getData('anti-aliasing');
		}

		updateHitbox();

        playAnim('static');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(animation.curAnim.name == 'confirm' && !PlayState.curUISkin.endsWith('-pixel'))
			centerOrigin();
	}

    public function playAnim(anim:String, ?force:Bool = false)
    {
		if(animation.getByName(anim) != null)
		{
			animation.play(anim, force);
		}

		centerOrigin();

		if(!PlayState.curUISkin.endsWith('-pixel'))
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;
	
			var scale = 0.7;
	
			offset.x -= 156 * scale / 2;
			offset.y -= 156 * scale / 2;
		}
		else
			centerOffsets();
    }
}
