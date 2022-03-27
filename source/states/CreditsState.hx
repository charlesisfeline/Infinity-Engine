package states;

import openfl.display.BitmapData;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import mods.Mods;
import ui.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

using StringTools;

// REMEMBER TO FINISH THIS AND CHARACTER EDITOR!!!!

class Credit
{
    public var name:String;
    public var description:String;
    public var color:String;

    public function new(name:String, description:String, color:String)
    {
        this.name = name;
        this.description = description;
        this.color = color;
    }
}

class CreditsState extends MusicBeatState
{
    var curSelected:Int = 0;

    var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

    var box:FlxSprite;
    var desc:FlxText;

    var json:Dynamic;

    var credits:Array<Credit> = [];

    var grpIcons:FlxTypedGroup<CreditsIcon>;
    var grpText:FlxTypedGroup<Alphabet>;

    override public function create()
    {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        add(bg);

        grpIcons = new FlxTypedGroup<CreditsIcon>();
        add(grpIcons);

        grpText = new FlxTypedGroup<Alphabet>();
        add(grpText);

        loadCredits();

        bg.color = FlxColor.fromString(Paths.getHexCode(credits[curSelected].color));

        box = new FlxSprite(0, FlxG.height * 0.8).makeGraphic(1, 1, FlxColor.BLACK);
        box.alpha = 0.6;
        add(box);

        desc = new FlxText(0, box.y + 5, FlxG.width - 10, "swag shit", 24);
        desc.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, CENTER);
        desc.screenCenter(X);
        add(desc);

        changeSelection();
        
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
		loadCredits();

		curSelected = 0;
		changeSelection();
	}

    function loadCredits()
    {
        credits = [];

        for(fuck in grpText.members)
        {
            fuck.kill();
            fuck.destroy();
        }

        for(fuck in grpIcons.members)
        {
            fuck.kill();
            fuck.destroy();
        }

        grpText.clear();
        grpIcons.clear();
        
        #if (MODS_ALLOWED && sys)
        if(Paths.currentMod == "Friday Night Funkin'" || !sys.FileSystem.exists(Sys.getCwd() + 'mods/' + Paths.currentMod + '/data/credits.json'))
        {
            json = Json.parse(Assets.getText('assets/data/credits.json')).credits;

            for(i in 0...json.length)
            {
                var credit = json[i];
                credits.push(new Credit(credit.name, credit.description, credit.color));
            }
        }
        #else
        json = Json.parse(Assets.getText('assets/data/credits.json')).credits;

        for(i in 0...json.length)
        {
            var credit = json[i];
            credits.push(new Credit(credit.name, credit.description, credit.color));
        }
        #end

		#if (MODS_ALLOWED && sys)
        var mod = Paths.currentMod;

        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/credits.json'))
        {
            var modJson = Json.parse(sys.io.File.getContent(Sys.getCwd() + 'mods/$mod/data/credits.json')).credits;

            for(i in 0...modJson.length)
            {
                var credit = modJson[i];
                credits.push(new Credit(credit.name, credit.description, credit.color));
            }
        }
		#end

        var credits_i:Int = 0;
        for(credit in credits)
        {
            var alphabet:Alphabet = new Alphabet(0, (70 * credits_i) + 30, credit.name);
            alphabet.isMenuItem = true;
            alphabet.targetY = credits_i;
            grpText.add(alphabet);

            alphabet.x += 200;
            //alphabet.xAdd = 100;
            //alphabet.yAdd -= 330;
            alphabet.forceX = 200;

			var icon:CreditsIcon = new CreditsIcon(alphabet.x - 105, alphabet.y, credit.name);
			icon.sprTracker = alphabet;
			grpIcons.add(icon);

            credits_i++;
        }
    }

    function changeSelection(?change:Int = 0)
    {
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;

		if (curSelected >= credits.length)
			curSelected = 0;

        var bullShit:Int = 0;
		for (item in grpText.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if (item.targetY == 0)
            {
                item.alpha = 1;
            }
        }

		var newColor:Int = FlxColor.fromString(Paths.getHexCode(credits[curSelected].color));
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

        desc.text = credits[curSelected].description;
        desc.screenCenter(X);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var ctrl = FlxG.keys.pressed.CONTROL;

        if(controls.BACK)
            FlxG.switchState(new MainMenuState());

        if(controls.UI_UP_P)
            changeSelection(-1);

        if(controls.UI_DOWN_P)
            changeSelection(1);

        if(ctrl)
		{
			if(controls.UI_LEFT_P)
				changeMod(-1);
			if(controls.UI_RIGHT_P)
				changeMod(1);
		}

        box.scale.x = desc.width + 10;
        box.scale.y = desc.height + 10;
        box.updateHitbox();
        box.screenCenter(X);
    }
}

class CreditsIcon extends FlxSprite
{
    public var page:Int = 0;

    public var sprTracker:FlxSprite;

    public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

    override public function new(x:Float, y:Float, icon:String)
    {
        super(x, y);

        icon = icon.toLowerCase();
        loadGraphic(Paths.image('credits/$icon', 'shared')); // it's in shared because the credit icons shouldn't need to be preloaded
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y + 30 + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}
    }
}