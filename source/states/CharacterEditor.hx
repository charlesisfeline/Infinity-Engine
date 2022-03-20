package states;

import texter.flixel.FlxInputTextRTL;
import mods.Mods;
import lime.utils.Assets;
import flixel.addons.ui.FlxUIInputText;
import lime.system.Clipboard;
import flixel.FlxObject;
import game.CharacterPart;
import game.Character;
import game.Stage;
import flixel.FlxG;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

using StringTools;

class CharacterEditor extends MusicBeatState
{
    var curSelected:Int = 0;
    var curCharacter:String = "dad";

    var flipX:Bool = false;
    var isPlayer:Bool = false;

    var camFollow:FlxObject;

    var stage:Stage;
    var stageJson:StageData;

    var character:CharacterPart;

    var box:FlxUI;

    var cameraZoom:Float = 1;

    var animListText:FlxText;

    var animList:Array<String> = [];

    override public function create()
    {
        super.create();

        FlxG.mouse.visible = true;
        Main.display.visible = false;

        stageJson = Paths.parseJson("stages/stage");

        stage = new Stage();
        stage.changeStage("stage");
        add(stage);

        character = new CharacterPart(0, 0, curCharacter);
        character.debugMode = true;

        character.x = stageJson.opponent[0];
        character.y = stageJson.opponent[1];

        character.x += character.json.position[0];
        character.y += character.json.position[1];

        add(character);

        add(stage.infrontOfGFSprites);
        add(stage.foregroundSprites);

        FlxG.camera.zoom = cameraZoom;

        camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.setPosition(character.getMidpoint().x, character.getMidpoint().y);
		add(camFollow);

        FlxG.camera.follow(camFollow);

        animListText = new FlxText(10, 10, 0, ">> your mother [99999999999, 9999999999]", 18);
        animListText.setFormat(Paths.font('vcr'), 18, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        animListText.borderSize = 2;
        animListText.scrollFactor.set();
        add(animListText);

        for(anim in character.anims)
        {
            //trace(anim.anim);
            animList.push(anim.anim);
        }

        //trace(animList);
        character.playAnim(animList[0], true);

        create_UI();
    }

    /*
    var animationInput:FlxUIInputText;
    var animationInput2:FlxUIInputText;

    var fpsInput:FlxUINumericStepper;

    var animBTN:FlxButton;
    var removeBTN:FlxButton;

    var animList:Array<String> = [];
    var animOffsets:Map<String, Array<Int>> = new Map<String, Array<Int>>();

    var animListText:FlxText;
    */

    var imageInput:FlxInputTextRTL;
    var loadBTN:FlxButton;

    function create_UI()
    {
        box = new FlxUI(null, null);
        box.scrollFactor.set();

		var tabs = [
			{name: "Animation", label: 'Animation'},
			{name: "Character", label: 'Character'}
        ];

        var uiBox = new FlxUITabMenu(null, tabs, false);

        uiBox.resize(400, 340);
        uiBox.x = (FlxG.width - uiBox.width) - 20;
        uiBox.y = 20;
        uiBox.scrollFactor.set();
        add(uiBox);

        // animation tab
        var animation_tab:FlxUI = new FlxUI(null, uiBox);
        animation_tab.name = 'Animation';

        var warnText:FlxText = new FlxText(10, 10, 0, "Character Name (Click \"Load\" to load the image)");
        imageInput = new FlxInputTextRTL(warnText.x, warnText.y + 20, 100, curCharacter, 8);

        loadBTN = new FlxButton(imageInput.x + (imageInput.width + 10), imageInput.y, "Load", function(){
            var char = imageInput.text;

            animList = [];

            character.anims = [];
            character.animOffsets.clear();
            character.loadCharacter(char);

            for(anim in character.anims)
            {
                //trace(anim.anim);
                animList.push(anim.anim);
            }

            curSelected = 0;
            changeSelection(0, false);

            character.playAnim(animList[curSelected]);
        });

        animation_tab.add(warnText);
        animation_tab.add(imageInput);
        animation_tab.add(loadBTN);
        
        // add tgeh shity
        uiBox.addGroup(animation_tab);
    }

    function loadFrames(char:String)
    {
        #if (MODS_ALLOWED && sys)
        for(mod in Mods.activeMods)
        {
            if(Mods.activeMods.length > 0)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$char/assets.png') && sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$char/assets.xml'))
                {
                    character.frames = Paths.getSparrowAtlas('characters/$char/assets', true);
                    return;
                }
            }
        }
        #end

        if(Assets.exists('assets/characters/$char/assets.png') && Assets.exists('assets/characters/$char/assets.xml'))
            character.frames = Paths.getSparrowAtlas('characters/$char/assets', true);
        else
            FlxG.sound.play(Paths.sound('cancelMenu'));
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		var inputTexts:Array<FlxInputTextRTL> = [imageInput];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				/*if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}*/
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.soundTrayEnabled = !inputTexts[i].hasFocus; // disables volume keys from workign
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

        var leftP = FlxG.keys.pressed.J;
        var downP = FlxG.keys.pressed.K;
        var upP = FlxG.keys.pressed.I;
        var rightP = FlxG.keys.pressed.L;

        var left = FlxG.keys.justPressed.LEFT;
        var down = FlxG.keys.justPressed.DOWN;
        var up = FlxG.keys.justPressed.UP;
        var right = FlxG.keys.justPressed.RIGHT;
        var shiftP = FlxG.keys.pressed.SHIFT;

        var camVelocity:Float = 190;

        if (FlxG.keys.justPressed.E)
        {
            cameraZoom += 0.1;

            if(cameraZoom > 10)
                cameraZoom = 10;

            FlxG.camera.zoom = cameraZoom;
        }

        if (FlxG.keys.justPressed.Q)
        {
            cameraZoom -= 0.1;

            if(cameraZoom < 0.1)
                cameraZoom = 0.1;

            FlxG.camera.zoom = cameraZoom;
        }

        if (FlxG.keys.justPressed.R)
        {
            cameraZoom = 1;
            FlxG.camera.zoom = cameraZoom;
        }

        var offsetMult = 1;
        if(shiftP)
            offsetMult = 10;

        if(FlxG.keys.justPressed.A)
            changeOffset(animList[curSelected], 'x', offsetMult * -1);

        if(FlxG.keys.justPressed.D)
            changeOffset(animList[curSelected], 'x', offsetMult);

        if(FlxG.keys.justPressed.W)
            changeOffset(animList[curSelected], 'y', offsetMult * -1);

        if(FlxG.keys.justPressed.S)
            changeOffset(animList[curSelected], 'y', offsetMult);

        if(upP || leftP || downP || rightP)
        {
            if(upP)
                camFollow.velocity.y = camVelocity * -1;
            else if (downP)
                camFollow.velocity.y = camVelocity;
            else
                camFollow.velocity.y = 0;

            if(leftP)
                camFollow.velocity.x = camVelocity * -1;
            else if(rightP)
                camFollow.velocity.x = camVelocity;
            else
                camFollow.velocity.x = 0;
        }
        else
            camFollow.velocity.set();

        if(controls.BACK)
        {
            Main.display.visible = true;
            FlxG.mouse.visible = false;
            FlxG.switchState(new MainMenuState());
        }

        if(up)
            changeSelection(-1);

        if(down)
            changeSelection(1);

        if(FlxG.keys.justPressed.SPACE)
            character.playAnim(character.animation.curAnim.name, true);

        animListText.text = "";

        for(i in 0...animList.length)
        {
            if(curSelected == i)
                animListText.text += ">> ";

            animListText.text += animList[i] + " [" + character.animOffsets.get(animList[i])[0] + ", " + character.animOffsets.get(animList[i])[1] + "]\n";
        }
    }

    function changeOffset(anim:String, axis:String, offsetMult:Int)
    {
        if(axis.toLowerCase() == 'x')
            character.animOffsets.set(anim, [character.animOffsets.get(anim)[0] + offsetMult * -1, character.animOffsets.get(anim)[1]]);
        else
            character.animOffsets.set(anim, [character.animOffsets.get(anim)[0], character.animOffsets.get(anim)[1] + offsetMult * -1]);

        character.playAnim(character.animation.curAnim.name, true);
    }

    function changeSelection(?change:Int = 0, ?playAnim:Bool = true)
    {
        curSelected += change;

        if(curSelected < 0)
            curSelected = animList.length - 1;

        if(curSelected > animList.length - 1)
            curSelected = 0;

        if(playAnim)
        {
            trace(animList[curSelected]);
            character.playAnim(animList[curSelected]);
        }
    }

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}