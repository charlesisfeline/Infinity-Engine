package game;

import haxe.Exception;
import game.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var validScore:Bool;

	var keyCount:Null<Int>;
	var ui_Skin:Null<String>;

	var stage:String;
	var gf:String;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Paths.parseJson('data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase()).song;

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:SwagSong):SwagSong
	{
		var swagShit:SwagSong = rawJson;
		swagShit.validScore = true;
		return swagShit;
	}
}
