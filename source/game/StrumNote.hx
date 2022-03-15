package game;

import states.PlayState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import options.Options;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class StrumNote extends FlxSprite
{
	public var noteData:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(x:Float, y:Float, noteData:Int, ?noteskin:String = "default")
	{
		super(x, y);

        this.noteData = noteData;
		loadNoteSkin(noteskin);

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
			case 1:
				x += swagWidth * 1;
			case 2:
				x += swagWidth * 2;
			case 3:
				x += swagWidth * 3;
		}
	}

	public function loadNoteSkin(?noteskin:String = "default")
	{
		if(noteskin.endsWith("-pixel"))
		{
			loadGraphic(Paths.image('ui-skins/$noteskin/notes'), true, 17, 17);

			animation.add('strum', [noteData]);
            animation.add('pressed', [noteData + 4], 12, false);
            animation.add('confirm', [noteData + 8], 24, false);

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
		} else {
			frames = Paths.getSparrowAtlas('ui-skins/$noteskin/notes');

            switch(noteData)
            {
                case 0:
			        animation.addByPrefix('arrowLEFT0', 'strum', 24, true);
                    animation.addByPrefix('left press', 'pressed', 24, false);
                    animation.addByPrefix('left confirm', 'confirm', 24, false);
                case 1:
			        animation.addByPrefix('arrowDOWN0', 'strum', 24, true);
                    animation.addByPrefix('down press', 'pressed', 24, false);
                    animation.addByPrefix('down confirm', 'confirm', 24, false);
                case 2:
			        animation.addByPrefix('arrowUP0', 'strum', 24, true);
                    animation.addByPrefix('up press', 'pressed', 24, false);
                    animation.addByPrefix('up confirm', 'confirm', 24, false);
                case 3:
			        animation.addByPrefix('arrowRIGHT0', 'strum');
                    animation.addByPrefix('right press', 'pressed', 24, false);
                    animation.addByPrefix('right confirm', 'confirm', 24, false);
            }

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = Options.getData('anti-aliasing');
		}

        playAnim('strum');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

    public function playAnim(anim:String, ?force:Bool = false)
    {
        animation.play(anim, force);
		centerOffsets();
		centerOrigin();
    }
}
