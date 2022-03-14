package states;

import game.Song;
import game.Highscore;
import flixel.tweens.FlxTween;
#if desktop
import util.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import util.CoolUtil;
import haxe.Json;
import mods.Mods;
import ui.Alphabet;
import ui.HealthIcon;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var vocals:FlxSound = new FlxSound();

	var selector:FlxText;

	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;

	static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
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
		scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();
		
		positionScore();
	}

	public function addSong(displayName:String, weekNum:Null<Int>, songName:String, songCharacter:String, color:String, difficulties:Array<String>)
	{
		songs.push(new SongMetadata(displayName, weekNum, songName, songCharacter, color, difficulties));
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

		/*#if sys
		weekJsonDirs = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/weeks/");
		#else
		weekJsonDirs = ["tutorial.json", "week1.json", "week2.json", "week3.json", "week4.json", "week5.json", "week6.json"];
		#end
		
		#if (MODS_ALLOWED && sys)
		for(mod in Mods.activeMods)
		{
			if(Mods.activeMods.length > 0)
			{
				if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/weeks/'))
				{
					var funnyArray = sys.FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/weeks');
					
					for(jsonThingy in funnyArray)
					{
						weekJsonDirs.push(jsonThingy);
					}
				}
			}
		}
		#end

		for(dir in weekJsonDirs)
		{
			if(dir.endsWith(".json"))
				weekJsons.push(dir.split(".json")[0]);
		}

		trace("ADDED WEEKS TO LIST");

		for(i in 0...weekJsons.length)
		{
			var week = weekJsons[i];

			var json:Dynamic = Paths.parseJson('weeks/$week');

			var jsonSongs:Array<FreeplaySong> = json.songs;

			for(song in jsonSongs)
			{
				addSong(song.displayName, i, song.song, song.icon, song.color, song.difficulties);
			}
		}*/

		var freeplaySongs:Array<FreeplaySong> = Json.parse(Assets.getText('assets/data/freeplaySongList.json')).songs;

		for(song in freeplaySongs)
		{
			addSong(song.displayName, null, song.song, song.icon, song.color, song.difficulties);
		}

		#if (MODS_ALLOWED && sys)
		for(mod in Mods.activeMods)
		{
			if(Mods.activeMods.length > 0)
			{
				if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/freeplaySongList.json'))
				{
					var modFreeplaySongs:Array<FreeplaySong> = Json.parse(sys.io.File.getContent(Sys.getCwd() + 'mods/$mod/data/freeplaySongList.json')).songs;

					for(song in modFreeplaySongs)
					{
						addSong(song.displayName, null, song.song, song.icon, song.color, song.difficulties);
					}
				}
			}
		}
		#end

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

		if(lastDifficultyName == '')
			lastDifficultyName = CoolUtil.defaultDifficulty;

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
	}

	var playing:String = "";

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var space = FlxG.keys.justPressed.SPACE;

		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		var songName:String = Paths.formatToSongPath(songs[curSelected].songName.toLowerCase());

		if(space && (playing != songName))
		{
			playing = songName;

			if (FlxG.sound.music != null) {
                FlxG.sound.music.stop();
            }

            if (vocals != null) {
                vocals.stop();
            }

            FlxG.sound.playMusic(Paths.inst(songName), 1, false);

			FlxG.sound.music.pause();

			vocals = FlxG.sound.play(Paths.voices(songName));

			vocals.pause();

			FlxG.sound.music.time = 0;
			vocals.time = 0;

			FlxG.sound.music.play();
			vocals.play();

            FlxG.sound.list.add(vocals);
		}
		else if (accepted)
		{
			var poop:String = Highscore.formatSong(songName, curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songName);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			LoadingState.loadAndSwitchState(new PlayState());
		}

		positionScore();
	}

	function positionScore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);

		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = "< " + CoolUtil.difficultyString() + " >";
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

		PlayState.storyWeek = null;

		switch(songName)
		{
			case 'tutorial':
				PlayState.storyWeek = 0;
			case 'bopeebo' | 'fresh' | 'dad-battle':
				PlayState.storyWeek = 1;
			case 'spookeez' | 'south' | 'monster':
				PlayState.storyWeek = 2;
			case 'pico' | 'philly-nice' | 'blammed':
				PlayState.storyWeek = 3;
			case 'satin-panties' | 'high' | 'm.i.l.f':
				PlayState.storyWeek = 4;
			case 'cocoa' | 'eggnog' | 'winter-horrorland':
				PlayState.storyWeek = 5;
			case 'senpai' | 'roses' | 'thorns':
				PlayState.storyWeek = 6;
		}

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

		if(songs[curSelected].difficulties != null && songs[curSelected].difficulties.length > 0)
		{
			// go through all difficulties and add them to the list
			var diffs:Array<String> = [];

			for(diff in songs[curSelected].difficulties)
			{
				diffs.push(diff);
			}

			CoolUtil.difficulties = diffs;
		}

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

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		if(newPos > -1)
			curDifficulty = newPos;
	}
}

typedef FreeplaySong = {
	var displayName:String;
	var song:String;
	var icon:String;
	var color:String;
	var difficulties:Array<String>;
}

class SongMetadata
{
	public var displayName:String = "???";
	public var songName:String = "???";
	public var songCharacter:String = "bf";
	public var color:String = "00FF00";
	public var week:Null<Int> = 0;
	public var difficulties:Array<String> = [];

	public function new(displayName:String, week:Null<Int>, song:String, songCharacter:String, color:String, difficulties:Array<String>)
	{
		this.displayName = displayName;
		this.week = week;
		this.songName = song;
		this.songCharacter = songCharacter;
		this.color = color;
		this.difficulties = difficulties;
	}
}
