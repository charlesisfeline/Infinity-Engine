package states;

import flixel.tweens.FlxTween;
#if desktop
import util.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var weekJsonDirs:Array<String> = [];
	var weekJsons:Array<String> = [];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		super.create();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		loadSongs();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();
	}

	public function addSong(displayName:String, weekNum:Int, songName:String, songCharacter:String, color:String)
	{
		songs.push(new SongMetadata(displayName, weekNum, songName, songCharacter, color));
	}

	public function loadSongs()
	{
		songs = [];

		for(shatt in grpSongs.members)
		{
			shatt.kill();
			shatt.destroy();
		}

		for(shatt in grpIcons.members)
		{
			shatt.kill();
			shatt.destroy();
		}

		grpSongs.clear();
		grpIcons.clear();

		#if sys
		weekJsonDirs = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/weeks/");
		#else
		weekJsonDirs = ["tutorial.json", "week1.json", "week2.json", "week3.json", "week4.json", "week5.json", "week6.json"];
		#end
		
		#if (MODS_ALLOWED && sys)
		if(sys.FileSystem.exists(Sys.getCwd() + 'mods/weeks/'))
		{
			var funnyArray = sys.FileSystem.readDirectory(Sys.getCwd() + 'mods/weeks');
			
			for(jsonThingy in funnyArray)
			{
				weekJsonDirs.push(jsonThingy);
			}
		}
		#end

		for(dir in weekJsonDirs)
		{
			if(dir.endsWith(".json"))
				weekJsons.push(dir.split(".json")[0]);
		}

		for(i in 0...weekJsonDirs.length)
		{
			var week = weekJsonDirs[i];

			var json:Dynamic = Paths.parseJson('assets/weeks/$week');
			var jsonSongs:Array<FreeplaySong> = json.songs;

			for(song in jsonSongs)
			{
				addSong(song.displayName, i, song.song, song.icon, song.color);
			}
		}

		// IMPROVE LATER!! I HAVE TO GO IN LIKE A FEW MINUTES!! SO I CAN'T FINISH THIS CORRECTLY RN
		// DO MODS/MOD/SHIT LATER

		bg.color = FlxColor.fromString(Paths.getHexCode(songs[0].color));

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].displayName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			grpIcons.add(icon);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyWeek = songs[curSelected].week;

		/*#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end*/ // nah

		var bullShit:Int = 0;

		for (icon in grpIcons)
		{
			icon.alpha = 0.6;
		}

		grpIcons.members[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		var newColor:Int = FlxColor.fromString(Paths.getHexCode(songs[curSelected].color));
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
	}
}

typedef FreeplaySong = {
	var displayName:String;
	var song:String;
	var icon:String;
	var color:String;
	var difficulties:String;
}

class SongMetadata
{
	public var displayName:String = "???";
	public var songName:String = "???";
	public var songCharacter:String = "bf";
	public var color:String = "00FF00";
	public var week:Int = 0;

	public function new(displayName:String, week:Int, song:String, songCharacter:String, color:String)
	{
		this.displayName = displayName;
		this.week = week;
		this.songName = song;
		this.songCharacter = songCharacter;
		this.color = color;
	}
}
