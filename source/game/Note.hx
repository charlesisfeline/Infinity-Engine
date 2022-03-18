package game;

import states.PlayState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import options.OptionsHandler;
import flixel.util.FlxColor;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var shouldHit:Bool = true;

	public var noteScore:Float = 1;
	public var originalHeightForCalcs:Float = 6;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?noteskin:String = "default")
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 100;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		loadNoteSkin(noteskin);
	}

	public function loadNoteSkin(?noteskin:String = "default")
	{
		if(noteskin.endsWith("-pixel"))
		{
			loadGraphic(Paths.image('ui-skins/$noteskin/notes'), true, 17, 17);

			animation.add('greenScroll', [6]);
			animation.add('redScroll', [7]);
			animation.add('blueScroll', [5]);
			animation.add('purpleScroll', [4]);

			if (isSustainNote)
			{
				loadGraphic(Paths.image('ui-skins/$noteskin/noteEnds'), true, 7, 6);
				originalHeightForCalcs = height;

				animation.add('purpleholdend', [4]);
				animation.add('greenholdend', [6]);
				animation.add('redholdend', [7]);
				animation.add('blueholdend', [5]);

				animation.add('purplehold', [0]);
				animation.add('greenhold', [2]);
				animation.add('redhold', [3]);
				animation.add('bluehold', [1]);
			}

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
			antialiasing = false;
		} else {
			frames = Paths.getSparrowAtlas('ui-skins/$noteskin/notes');

			animation.addByPrefix('purpleScroll', 'A0');
			animation.addByPrefix('blueScroll', 'B0');
			animation.addByPrefix('greenScroll', 'C0');
			animation.addByPrefix('redScroll', 'D0');

			animation.addByPrefix('purpleholdend', 'A tail0');
			animation.addByPrefix('blueholdend', 'B tail0');
			animation.addByPrefix('greenholdend', 'C tail0');
			animation.addByPrefix('redholdend', 'D tail0');

			animation.addByPrefix('purplehold', 'A hold0');
			animation.addByPrefix('bluehold', 'B hold0');
			animation.addByPrefix('greenhold', 'C hold0');
			animation.addByPrefix('redhold', 'D hold0');

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = Options.getData('anti-aliasing');
		}

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				playAnim('purpleScroll');
			case 1:
				x += swagWidth * 1;
				playAnim('blueScroll');
			case 2:
				x += swagWidth * 2;
				playAnim('greenScroll');
			case 3:
				x += swagWidth * 3;
				playAnim('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			if(Options.getData('downscroll'))
				flipY = true;

			switch (noteData)
			{
				case 2:
					playAnim('greenholdend');
				case 3:
					playAnim('redholdend');
				case 1:
					playAnim('blueholdend');
				case 0:
					playAnim('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curUISkin.endsWith('-pixel'))
				x += 30;
			/*else
				x += 35;*/

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.playAnim('purplehold');
					case 1:
						prevNote.playAnim('bluehold');
					case 2:
						prevNote.playAnim('greenhold');
					case 3:
						prevNote.playAnim('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.52 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		calculateCanBeHit();

		if(tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function calculateCanBeHit()
	{
		if(this != null)
		{
			if(mustPress)
			{
				if (isSustainNote)
				{
					if(shouldHit)
					{
						if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
							&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
							canBeHit = true;
						else
							canBeHit = false;
					}
					else
					{
						if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
							&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
							canBeHit = true;
						else
							canBeHit = false;
					}
				}
				else
				{
					if(shouldHit)
					{
						if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
							&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
							canBeHit = true;
						else
							canBeHit = false;
					}
					else
					{
						if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
							&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
							canBeHit = true;
						else
							canBeHit = false;
					}
				}
	
				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
					tooLate = true;
			}
			else
			{
				canBeHit = false;
	
				if (strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}
	}

    public function playAnim(anim:String, ?force:Bool = false)
	{
		if(animation.getByName(anim) != null)
		{
			animation.play(anim, force);
		}
	}
}
