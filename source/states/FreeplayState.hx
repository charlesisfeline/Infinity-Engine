package states;

import openfl.display.BitmapData;
import util.Cache;
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
import flixel.math.FlxMath;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var vocals:FlxSound = new FlxSound();

	var selector:FlxText;

	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;
	static var curSpeed:Float = 1;

	static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var speedText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var holdTime:Float = 0;

	var weekJsonDirs:Array<String> = [];
	var weekJsons:Array<String> = [];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		super.create();

		Cache.clearCache();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
		scoreText.alignment = CENTER;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		loadSongs();
		//trace('load songs');

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.alignment = CENTER;
		add(diffText);

		speedText = new FlxText(FlxG.width, diffText.y + 36, 0, "", 24);
		speedText.font = scoreText.font;
		speedText.alignment = CENTER;
		add(speedText);

		curSpeed = FlxMath.roundDecimal(curSpeed, 2);

		#if !sys
		curSpeed = 1;
		#end

		if(curSpeed < 0.25)
			curSpeed = 0.25;

		#if sys
		speedText.text = "Speed: " + curSpeed + " (SHIFT+R)";
		#else
		speedText.text = "";
		#end

		add(scoreText);

		changeSelection();
		changeDiff();
		
		positionScore();

		currentModText = new FlxText(FlxG.width, 5, 0, "among us?", 24);
		currentModText.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, RIGHT);
		currentModText.alignment = RIGHT;

		currentModBG = new FlxSprite(currentModText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
		currentModBG.alpha = 0.6;

		var bitmapData:BitmapData = null;

        #if (MODS_ALLOWED && sys)
		var mod = Paths.currentMod;

        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/_mod_icon.png'))
        {
            bitmapData = BitmapData.fromFile(Sys.getCwd() + 'mods/$mod/_mod_icon.png');
			currentModIcon = new FlxSprite().loadGraphic(bitmapData);
		}
		else
		{
			currentModIcon = new FlxSprite().loadGraphic(Paths.image('unknown_mod', 'shared'));
		}
		#else
		currentModIcon = new FlxSprite().loadGraphic(Paths.image('unknown_mod', 'shared'));
		#end

		add(currentModBG);
		add(currentModText);
		add(currentModIcon);

		positionCurrentMod();

		var switchWarn:FlxText = new FlxText(0, currentModBG.y - (currentModBG.height + 6), 0, "[CTRL + LEFT/RIGHT to switch mods]");
		switchWarn.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		switchWarn.borderSize = 2;
		add(switchWarn);

		switchWarn.x = FlxG.width - (switchWarn.width + 8);
	}
	
	// CURRENT MOD SHIT
	var currentModBG:FlxSprite;
	var currentModText:FlxText;

	var currentModIcon:FlxSprite;

	function positionCurrentMod()
	{
		currentModText.text = Paths.currentMod;
		currentModText.setPosition(FlxG.width - (currentModText.width + 6), FlxG.height - (currentModText.height + 6));

		currentModBG.makeGraphic(Math.floor(currentModText.width + 8), Math.floor(currentModText.height + 8), 0xFF000000);
		currentModBG.setPosition(FlxG.width - currentModBG.width, FlxG.height - currentModBG.height);

		var bitmapData:BitmapData = null;

        #if (MODS_ALLOWED && sys)
		var mod = Paths.currentMod;

        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/_mod_icon.png'))
        {
            bitmapData = BitmapData.fromFile(Sys.getCwd() + 'mods/$mod/_mod_icon.png');
			currentModIcon.loadGraphic(bitmapData);
		}
		else
		{
			currentModIcon.loadGraphic(Paths.image('unknown_mod', 'shared'));
		}
		#else
		currentModIcon.loadGraphic(Paths.image('unknown_mod', 'shared'));
		#end

		currentModIcon.setGraphicSize(Math.floor(currentModBG.height));
		currentModIcon.updateHitbox();

		currentModIcon.setPosition(currentModBG.x - (currentModIcon.width), currentModBG.y);
	}

	function changeMod(?change:Int = 0)
	{
		var index:Int = Mods.activeMods.indexOf(Paths.currentMod);

		index += change;

		if(index < 0)
			index = Mods.activeMods.length - 1;

		if(index > Mods.activeMods.length - 1)
			index = 0;

		Paths.currentMod = Mods.activeMods[index];

		bg.loadGraphic(Paths.image('menuDesat'));

		positionCurrentMod();
		loadSongs();

		curSelected = 0;
		changeSelection();
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

		if(Paths.currentMod == "Vanilla FNF")
		{
			var freeplaySongs:Array<FreeplaySong> = Json.parse(Assets.getText('assets/data/freeplaySongList.json')).songs;

			for(song in freeplaySongs)
			{
				addSong(song.displayName, null, song.song, song.icon, song.color, song.difficulties);
			}
		}

		#if (MODS_ALLOWED && sys)
		var mod = Paths.currentMod;

		if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/freeplaySongList.json'))
		{
			var modFreeplaySongs:Array<FreeplaySong> = Json.parse(sys.io.File.getContent(Sys.getCwd() + 'mods/$mod/data/freeplaySongList.json')).songs;

			for(song in modFreeplaySongs)
			{
				addSong(song.displayName, null, song.song, song.icon, song.color, song.difficulties);
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

		var funnyObject:FlxText = scoreText;

		if(speedText.width >= scoreText.width && speedText.width >= diffText.width)
			funnyObject = speedText;

		if(diffText.width >= scoreText.width && diffText.width >= speedText.width)
			funnyObject = diffText;

		scoreBG.x = funnyObject.x - 6;

		if(Std.int(scoreBG.width) != Std.int(funnyObject.width + 6))
			scoreBG.makeGraphic(Std.int(funnyObject.width + 6), 108, FlxColor.BLACK);

		curSpeed = FlxMath.roundDecimal(curSpeed, 2);

		#if !sys
		curSpeed = 1;
		#end

		if(curSpeed < 0.25)
			curSpeed = 0.25;

		#if sys
		speedText.text = "Speed: " + curSpeed + " (R+SHIFT)";
		#else
		speedText.text = "";
		#end

		var left = controls.UI_LEFT;
		var right = controls.UI_RIGHT;

		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var shift = FlxG.keys.pressed.SHIFT;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var space = FlxG.keys.justPressed.SPACE;

		var ctrl = FlxG.keys.pressed.CONTROL;

		var accepted = controls.ACCEPT;

		if(-1 * Math.floor(FlxG.mouse.wheel) != 0 && !shift)
			changeSelection(-1 * Math.floor(FlxG.mouse.wheel));
		else if(-1 * (Math.floor(FlxG.mouse.wheel) / 10) != 0 && shift)
		{
			curSpeed += -1 * (Math.floor(FlxG.mouse.wheel) / 10);

			#if cpp
			@:privateAccess
			{
				if(FlxG.sound.music.active && FlxG.sound.music.playing)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
	
				if (vocals.active && vocals.playing)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			}
			#end
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if(!ctrl)
		{
			if(leftP && !shift)
				changeDiff(-1);
			if(rightP && !shift)
				changeDiff(1);
			if((left || right) && shift) {
				var daMultiplier:Float = left ? -0.05 : 0.05;

				holdTime += elapsed;

				if(holdTime > 0.5 || leftP || rightP)
				{
					curSpeed += daMultiplier;
		
					if(curSpeed < 0.25)
						curSpeed = 0.25;

					#if cpp
					@:privateAccess
					{
						if(FlxG.sound.music.active && FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			
						if (vocals.active && vocals.playing)
							lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
					}
					#end
				}
			} else {
				holdTime = 0;
			}
		}
		else
		{
			if(leftP && !shift)
				changeMod(-1);
			if(rightP && !shift)
				changeMod(1);
		}

		if(shift && FlxG.keys.justPressed.R)
		{
			curSpeed = 1;

			#if cpp
			@:privateAccess
			{
				if(FlxG.sound.music.active && FlxG.sound.music.playing)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
	
				if (vocals.active && vocals.playing)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			}
			#end
		}

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

			#if cpp
			@:privateAccess
			{
				if(FlxG.sound.music.active && FlxG.sound.music.playing && !FlxG.keys.justPressed.ENTER)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
	
				if(vocals.active && vocals.playing && !FlxG.keys.justPressed.ENTER)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			}
			#end
		}
		else if (accepted)
		{
			var poop:String = Highscore.formatSong(songName, curDifficulty);

			//trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songName);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.songMultiplier = curSpeed;

			LoadingState.loadAndSwitchState(new PlayState());
		}

		positionScore();
	}

	function positionScore()
	{
		scoreBG.x = FlxG.width - (scoreBG.width);

		scoreText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		scoreText.x -= scoreText.width / 2;

		speedText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		speedText.x -= speedText.width / 2;

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
		var songName:String = Paths.formatToSongPath(songs[curSelected].songName.toLowerCase());
		
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
