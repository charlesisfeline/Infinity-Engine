package mods;

#if desktop
import util.Discord.DiscordClient;
#end
import states.MusicBeatState;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import states.MainMenuState;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import mods.Mods.ModInfo;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class ModsState extends MusicBeatState
{
    var menuBG:FlxSprite;
    var menuColor:Int = 0xFF4359A8;

    var modGroup:FlxTypedGroup<ModGroup> = new FlxTypedGroup<ModGroup>();

    var curSelected:Int = 0;

    var camFollow:FlxObject;

    var noMods:Bool = false;

    var modsList:Array<Array<Dynamic>> = [];

    override public function create()
    {
        for(mod in Mods.mods)
        {
            if(mod[0] != "Friday Night Funkin'")
                modsList.push(mod);
        }

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;
        
        FlxG.camera.scroll.set();
		FlxG.camera.target = null;

        menuBG = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = menuColor;
        menuBG.scrollFactor.set();
		add(menuBG);

        add(modGroup);

        Mods.getAllMods();
        
        if(modsList.length < 1)
        {
            noMods = true;

            var oopsText:FlxText = new FlxText(0, 0, 0, "You have no mods installed.\nPlease put one in your mods folder\nand press R to reload.", 24);
            oopsText.font = Paths.font("vcr");
            oopsText.borderStyle = OUTLINE;
            oopsText.borderSize = 3;
            oopsText.borderColor = FlxColor.BLACK;

            oopsText.screenCenter();
            add(oopsText);
        }
        
        for(modIndex in 0...modsList.length)
        {
            var mod = modsList[modIndex];

            var funnyGroup = new ModGroup(0, 100 + (250 * modIndex), mod);
            funnyGroup.screenCenter(X);

            modGroup.add(funnyGroup);
        }

        camFollow = new FlxObject(0, 100, 1, 1);
        camFollow.screenCenter(X);
        add(camFollow);

        FlxG.camera.follow(camFollow, LOCKON, 0.1 * (60 / Main.display.currentFPS));

        updateMods();

        super.create();

        #if desktop
        DiscordClient.changePresence("In Mods Menu", null);
        #end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        FlxG.camera.followLerp = 0.1 * (60 / Main.display.currentFPS);

        var up = controls.UI_UP_P;
        var down = controls.UI_DOWN_P;
        var accept = controls.ACCEPT;

        if(noMods && FlxG.keys.justPressed.R)
            FlxG.resetState();

        if(up || down)
        {
            if(up)
                curSelected -= 1;

            if(down)
                curSelected += 1;

            if(curSelected < 0)
                curSelected = modsList.length - 1;

            if(curSelected > modsList.length - 1)
                curSelected = 0;

            updateMods();

            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        if(accept)
        {
            var modName = modsList[curSelected][0];
            Mods.setModActive(modName, !Mods.getModActive(modName));

            updateMods();
        }

        if(controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(new MainMenuState());
        }
    }

    function updateMods()
    {
        for(modIndex in 0...modGroup.members.length)
        {
            var mod = modGroup.members[modIndex];

            if(modIndex == curSelected)
            {
                mod.alpha = 1;
                camFollow.setPosition(camFollow.x, mod.getGraphicMidpoint().y + 200);
            }
            else
                mod.alpha = 0.6;
        }

        for(selected in 0...modsList.length)
        {
            var modName = modsList[selected][0];

            modGroup.members[selected].funnyIndicator.text = Mods.getModActive(modName) == false ? "[ OFF ]" : "[ ON  ]";
            modGroup.members[selected].funnyIndicator.color = Mods.getModActive(modName) == false ? FlxColor.RED : FlxColor.LIME;
        }
    }
}

// MODS MENU CRASHES THE GAME!!!!
// REMINDER TO FIX!!!!!!!!!!!!!!!

class ModGroup extends FlxSpriteGroup
{
    public var tracker:FlxObject;
    public var funnyIndicator:FlxText;

    public function new(x:Float = 0, y:Float = 0, mod:Array<Dynamic>)
    {
        super(x, y);

        tracker = new FlxObject(x,y,1,1);

        var bg:FlxSprite = new FlxSprite(0,0);
        bg.makeGraphic(615, 200, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        var funnyData:ModInfo = Paths.parseJson(mod[0] + "/_mod_info", true);

        var modName:FlxText = new FlxText(5, 5, 450, funnyData.name, 24);
        modName.font = Paths.font("vcr");
        modName.borderStyle = OUTLINE;
        modName.borderSize = 3;
        modName.borderColor = FlxColor.BLACK;
        modName.wordWrap = false;
        add(modName);

        var modDescription:FlxText = new FlxText(modName.x, 33, 450, funnyData.description, 24);
        modDescription.font = Paths.font("vcr");
        modDescription.borderStyle = OUTLINE;
        modDescription.borderSize = 2;
        modDescription.borderColor = FlxColor.BLACK;
        add(modDescription);

        var modAuthor:FlxText = new FlxText(610, 195, 0, "By: " + funnyData.author, 16);
        modAuthor.font = Paths.font("vcr");
        modAuthor.borderStyle = OUTLINE;
        modAuthor.borderSize = 1.5;
        modAuthor.borderColor = FlxColor.BLACK;
        modAuthor.x -= modAuthor.width;
        modAuthor.y -= modAuthor.height;
        add(modAuthor);

        var funnySprite:FlxSprite = new FlxSprite(460, 5);
        
        #if (MODS_ALLOWED && sys)
        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/${mod[0]}/_mod_icon.png'))
        {
            var bitmapData:BitmapData = BitmapData.fromFile(Sys.getCwd() + 'mods/${mod[0]}/_mod_icon.png');

            funnySprite.loadGraphic(bitmapData, false, 0, 0, false, 'mods/${mod[0]}/_mod_icon.png');
            funnySprite.setGraphicSize(150, 150);
        }
        else
        {
        #end
        funnySprite.makeGraphic(150, 150, FlxColor.GRAY);
        #if (MODS_ALLOWED && sys)
        }
        #end

        funnySprite.updateHitbox();

        add(funnySprite);

        funnyIndicator = new FlxText(5, 195, 0, Mods.getModActive(mod[0]) == false ? "[ OFF ]" : "[ ON  ]", 16);
        funnyIndicator.font = Paths.font("vcr");
        funnyIndicator.borderStyle = OUTLINE;
        funnyIndicator.borderSize = 1.5;
        funnyIndicator.borderColor = FlxColor.BLACK;
        funnyIndicator.y -= funnyIndicator.height;
        funnyIndicator.color = Mods.getModActive(mod[0]) == false ? FlxColor.RED : FlxColor.LIME;
        add(funnyIndicator);
    }
}