package states;

import flixel.addons.ui.FlxUIDropDownMenu;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import haxe.Json;
import openfl.events.Event;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUICheckBox;
import flixel.math.FlxMath;
import util.CoolUtil;
import options.OptionsHandler;
import flixel.FlxCamera;
import flixel.ui.FlxBar;
import ui.HealthIcon;
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
import ui.FlxUIDropDownMenuCustom;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

// REMEMBER TO FINISH THIS LOL!!!!!!!!!!!1

using StringTools;

class CharacterEditor extends MusicBeatState
{
    var icons:FlxTypedGroup<HealthIcon>;

    var curSelected:Int = 0;
    var curCharacter:String = "dad";

    var flipX:Bool = false;
    var isPlayer:Bool = false;
    var noAntialiasing:Bool = false;

    var healthColor:Array<Int> = [0, 0, 0];
    var singDuration:Float = 4;
    var scale:Float = 1;

    var camFollow:FlxObject;

    var camGame:FlxCamera;
    var camHUD:FlxCamera;

    var stage:Stage;
    var stageJson:StageData;

    var character:CharacterPart;

    var box:FlxUI;

    var cameraZoom:Float = 1;

    var animListText:FlxText;

    var healthBarBG:FlxSprite;
    var healthBar:FlxBar;

    var animList:Array<String> = [];

    var cameraFollowPointer:FlxSprite;

    var charData:Dynamic;

    override public function create()
    {
        super.create();

        FlxG.mouse.visible = true;
        Main.display.visible = false;

		camHUD = new FlxCamera();
		camGame = new FlxCamera();
        camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset();

		FlxG.cameras.add(camGame, true);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.camera = camGame;

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

        singDuration = character.json.sing_duration;
        healthColor = character.healthColor;
        scale = character.json.scale;

        flipX = character.json.flip_x;

        if(isPlayer)
            flipX = !flipX;

        character.flipX = flipX;

        noAntialiasing = character.json.no_antialiasing;

        add(stage.infrontOfGFSprites);
        add(stage.foregroundSprites);

        FlxG.camera.zoom = cameraZoom;

        camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.setPosition(character.getMidpoint().x, character.getMidpoint().y);
		add(camFollow);

        FlxG.camera.follow(camFollow);

        var iconSpacingLol:Int = 40;

		healthBarBG = new FlxSprite(iconSpacingLol, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar', 'shared'));
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = Options.getData('anti-aliasing');
        healthBarBG.cameras = [camHUD];
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

        var color = FlxColor.fromRGB(character.healthColor[0], character.healthColor[1], character.healthColor[2]);
		healthBar.createFilledBar(color, color);

        healthBar.cameras = [camHUD];
		add(healthBar);

        icons = new FlxTypedGroup<HealthIcon>();
        add(icons);

        for(i in 0...3)
        {
            var icon:HealthIcon = new HealthIcon(curCharacter, false);
            icon.setPosition(iconSpacingLol + (i * 130), healthBarBG.y - (icon.height / 2));
            icon.scrollFactor.set();
            icon.cameras = [camHUD];

            icons.add(icon);
        }

        animListText = new FlxText(10, 10, 0, ">> your mother [99999999999, 9999999999]", 18);
        animListText.setFormat(Paths.font('vcr'), 18, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        animListText.borderSize = 2;
        animListText.scrollFactor.set();
        animListText.cameras = [camHUD];
        add(animListText);

        for(anim in character.anims)
        {
            //trace(anim.anim);
            animList.push(anim.anim);
        }

		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);

        updatePointerPos();

        //trace(animList);
        character.playAnim(animList[0], true);

        create_UI();

        reloadAnimationDropDown();
    }

	function updatePointerPos()
    {
        var x:Float = character.getMidpoint().x;
        var y:Float = character.getMidpoint().y;
        if(!character.isPlayer) {
            x += 150 + character.json.camera_position[0];
        } else {
            x -= 100 + character.json.camera_position[0];
        }
        y -= 100 - character.json.camera_position[1];

        x -= cameraFollowPointer.width / 2;
        y -= cameraFollowPointer.height / 2;
        cameraFollowPointer.setPosition(x, y);
    }

	function reloadAnimationDropDown()
    {
		var anims:Array<String> = [];

		for (anim in character.anims)
        {
			anims.push(anim.anim);
		}

		if(anims.length < 1) anims.push('No Animations Available'); // prevents a stinky doo doo fard crash!! :) :D

		animationDropdown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(anims, true));
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

    // animation tab shit
    var animationDropdown:FlxUIDropDownMenuCustom;

    var animNameInput:FlxInputTextRTL;
    var animInput:FlxInputTextRTL;
    var indicesInput:FlxInputTextRTL;

    var fpsStepper:FlxUINumericStepper;

    // character tab shit
    var imageInput:FlxInputTextRTL;
    var iconInput:FlxInputTextRTL;

    var loadBTN:FlxButton;
    var iconColorBTN:FlxButton;

    var singDurationStepper:FlxUINumericStepper;
    var scaleStepper:FlxUINumericStepper;

    var healthColorStepper1:FlxUINumericStepper;
    var healthColorStepper2:FlxUINumericStepper;
    var healthColorStepper3:FlxUINumericStepper;
    
    var charFlipBox:FlxUICheckBox;
    var charPlayerBox:FlxUICheckBox;
    var noAntialiasingBox:FlxUICheckBox;

    var characterXStepper:FlxUINumericStepper;
    var characterYStepper:FlxUINumericStepper;

    var camXStepper:FlxUINumericStepper;
    var camYStepper:FlxUINumericStepper;

    var saveBTN:FlxButton;

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

        trace("aninm pass");

        var warnText:FlxText = new FlxText(10, 10, 0, "Animations");

        trace("aninm warn pass");

		animationDropdown = new FlxUIDropDownMenuCustom(warnText.x, warnText.y + 20, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(pressed:String) {
            // do nothing for now i guess lmao
		});

        trace("aninm dorpdwon pass");

        var warnText2:FlxText = new FlxText(warnText.x, animationDropdown.y + 30, 0, "Animation Name");
        animNameInput = new FlxInputTextRTL(warnText.x, warnText2.y + 20, 75, character.anims[curSelected].anim, 8);

        trace("warn2 pass");

        var warnText3:FlxText = new FlxText(warnText.x, animNameInput.y + 20, 0, "Animation in XML/TXT file");
        animInput = new FlxInputTextRTL(warnText.x, warnText3.y + 20, 150, character.anims[curSelected].name, 8);

        trace("warn3 pass");

        var warnText4:FlxText = new FlxText(warnText.x, animInput.y + 20, 0, "Animation Indices");

        var indicesStr = character.anims[curSelected].indices.toString();
        indicesInput = new FlxInputTextRTL(warnText.x, warnText4.y + 20, 220, indicesStr.substr(1, indicesStr.length - 2), 8);

        trace("warn4 pass");

        var warnText5:FlxText = new FlxText(animInput.x + (animInput.width + 10), warnText2.y, 0, "Framerate");
        fpsStepper = new FlxUINumericStepper(animInput.x + (animInput.width + 10), animNameInput.y, 1, 24, 0, 999);
        fpsStepper.value = character.anims[curSelected].fps;
        fpsStepper.name = "FPS";

        trace("fps pass");

        animation_tab.add(warnText);
        //animation_tab.add(animationDropdown);

        animation_tab.add(warnText2);
        animation_tab.add(animNameInput);

        animation_tab.add(warnText3);
        animation_tab.add(animInput);

        animation_tab.add(warnText4);
        animation_tab.add(indicesInput);

        animation_tab.add(warnText5);
        animation_tab.add(fpsStepper);

        // ANIMATION TAB DROPDOWNS
        // WE ADD THEM AFTER BECAUSE OF ORDERING REASONS LOL!!!
        animation_tab.add(animationDropdown);

        // character tab
        var character_tab:FlxUI = new FlxUI(null, uiBox);
        character_tab.name = 'Character';

        var warnText:FlxText = new FlxText(10, 10, 0, "Character Name (Click \"Load\" to load the image)");
        imageInput = new FlxInputTextRTL(warnText.x, warnText.y + 20, 150, curCharacter, 8);

        loadBTN = new FlxButton(imageInput.x + (imageInput.width + 10), imageInput.y - 2, "Load", function(){
            var char = imageInput.text;

            iconInput.text = char;

            animList = [];

            character.anims = [];
            character.animOffsets.clear();
            character.loadCharacter(char);

            character.x = stageJson.opponent[0];
            character.y = stageJson.opponent[1];
    
            character.x += character.json.position[0];
            character.y += character.json.position[1];

            for(anim in character.anims)
            {
                //trace(anim.anim);
                animList.push(anim.anim);
            }

            curSelected = 0;
            changeSelection(0, false);

            var color = FlxColor.fromRGB(character.healthColor[0], character.healthColor[1], character.healthColor[2]);
            healthBar.createFilledBar(color, color);
            
            singDuration = character.json.sing_duration;
            healthColor = character.healthColor;
            scale = character.json.scale;

            singDurationStepper.value = singDuration;
            scaleStepper.value = scale;

            healthColorStepper1.value = healthColor[0];
            healthColorStepper2.value = healthColor[1];
            healthColorStepper3.value = healthColor[2];

            flipX = character.json.flip_x;

            if(isPlayer)
                flipX = !flipX;
    
            character.flipX = flipX;

            noAntialiasing = character.json.no_antialiasing;

            charFlipBox.checked = flipX;
            charPlayerBox.checked = isPlayer;
            noAntialiasingBox.checked = noAntialiasing;

            characterXStepper.value = character.json.position[0];
            characterYStepper.value = character.json.position[1];

            camXStepper.value = character.json.camera_position[0];
            camYStepper.value = character.json.camera_position[1];

            animNameInput.text = character.anims[curSelected].anim;
            animInput.text = character.anims[curSelected].name;

            var indicesStr = character.anims[curSelected].indices.toString();
            indicesInput.text = indicesStr.substr(1, indicesStr.length - 2);

            updatePointerPos();

            character.playAnim(animList[curSelected]);
        });

        var warnText2:FlxText = new FlxText(warnText.x, imageInput.y + 20, 0, "Health Icon Name");
        iconInput = new FlxInputTextRTL(warnText2.x, warnText2.y + 20, 75, curCharacter, 8);

        iconColorBTN = new FlxButton(loadBTN.x, iconInput.y - 2, "Get Icon Color", function(){
            var coolColor = FlxColor.fromInt(CoolUtil.dominantColor(icons.members[0]));
            healthColorStepper1.value = coolColor.red;
            healthColorStepper2.value = coolColor.green;
            healthColorStepper3.value = coolColor.blue;
            getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepper1, null);
            getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepper2, null);
            getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepper3, null); 
        });

        var warnText3:FlxText = new FlxText(warnText.x, iconInput.y + 25, 0, "Sing Duration");
        singDurationStepper = new FlxUINumericStepper(iconInput.x, warnText3.y + 20, 0.1, singDuration, 0.1, 10, 1);
        singDurationStepper.value = singDuration;
        singDurationStepper.name = "SingDuration";

        var warnText4:FlxText = new FlxText(warnText.x, singDurationStepper.y + 20, 0, "Character Scale");
        scaleStepper = new FlxUINumericStepper(iconInput.x, warnText4.y + 20, 0.05, scale, 0.05, 10, 2);
        scaleStepper.value = scale;
        scaleStepper.name = "Scale";

        charFlipBox = new FlxUICheckBox(singDurationStepper.x + (singDurationStepper.width + 20), singDurationStepper.y, null, null, "Flip X", 80);
        charFlipBox.checked = flipX;

        charFlipBox.callback = function()
        {
            flipX = charFlipBox.checked;

            if(isPlayer)
                flipX = !flipX;

            character.flipX = flipX;
        };

        charPlayerBox = new FlxUICheckBox(iconInput.x + (iconInput.width + 10), iconInput.y, null, null, "Is Player", 80);
        charPlayerBox.checked = isPlayer;

        charPlayerBox.callback = function()
        {
            isPlayer = charPlayerBox.checked;

            flipX = charFlipBox.checked;

            if(isPlayer)
                flipX = !flipX;

            character.flipX = flipX;
        };

        noAntialiasingBox = new FlxUICheckBox(singDurationStepper.x + (singDurationStepper.width + 20), scaleStepper.y, null, null, "No Anti-Aliasing", 80);
        noAntialiasingBox.checked = noAntialiasing;

        noAntialiasingBox.callback = function()
        {
            noAntialiasing = noAntialiasingBox.checked;

            character.antialiasing = !noAntialiasing;
        };

        var warnText5:FlxText = new FlxText(warnText.x, scaleStepper.y + 20, 0, "Health Bar Color (R/G/B)");

        healthColorStepper1 = new FlxUINumericStepper(warnText5.x, warnText5.y + 20, 1, healthColor[0], 0, 255);
        healthColorStepper1.value = healthColor[0];
        healthColorStepper1.name = "Health1";

        healthColorStepper2 = new FlxUINumericStepper(healthColorStepper1.x + (healthColorStepper1.width + 10), healthColorStepper1.y, 1, healthColor[1], 0, 255);
        healthColorStepper2.value = healthColor[1];
        healthColorStepper2.name = "Health2";

        healthColorStepper3 = new FlxUINumericStepper(healthColorStepper2.x + (healthColorStepper2.width + 10), healthColorStepper1.y, 1, healthColor[2], 0, 255);
        healthColorStepper3.value = healthColor[2];
        healthColorStepper3.name = "Health3";

        var warnText6:FlxText = new FlxText(charFlipBox.x + (charFlipBox.width + 10), warnText3.y, 0, "Character Position");

        characterXStepper = new FlxUINumericStepper(charFlipBox.x + (charFlipBox.width + 10), charFlipBox.y, 1, character.json.position[0], -9999, 9999);
        characterXStepper.value = character.json.position[0];
        characterXStepper.name = "CharX";

        characterYStepper = new FlxUINumericStepper(characterXStepper.x + (characterXStepper.width + 10), charFlipBox.y, 1, character.json.position[1], -9999, 9999);
        characterYStepper.value = character.json.position[1];
        characterYStepper.name = "CharY";

        var warnText7:FlxText = new FlxText(warnText6.x, characterYStepper.y + 20, 0, "Camera Position");

        camXStepper = new FlxUINumericStepper(charFlipBox.x + (charFlipBox.width + 10), warnText7.y + 20, 1, character.json.position[0], -9999, 9999);
        camXStepper.value = character.json.camera_position[0];
        camXStepper.name = "CamX";

        camYStepper = new FlxUINumericStepper(characterXStepper.x + (characterXStepper.width + 10), camXStepper.y, 1, character.json.position[1], -9999, 9999);
        camYStepper.value = character.json.camera_position[1];
        camYStepper.name = "CamY";

        saveBTN = new FlxButton(healthColorStepper3.x + (healthColorStepper3.width + 10), healthColorStepper3.y - 2, "Save Char", function(){
            setCharacterData();
            saveCharacterJSON();
        });

        character_tab.add(warnText);
        character_tab.add(imageInput);
        character_tab.add(loadBTN);

        character_tab.add(warnText2);
        character_tab.add(iconInput);
        character_tab.add(iconColorBTN);

        character_tab.add(warnText3);
        character_tab.add(singDurationStepper);

        character_tab.add(warnText4);
        character_tab.add(scaleStepper);
        character_tab.add(charFlipBox);
        character_tab.add(charPlayerBox);
        character_tab.add(noAntialiasingBox);

        character_tab.add(warnText5);
        character_tab.add(healthColorStepper1);
        character_tab.add(healthColorStepper2);
        character_tab.add(healthColorStepper3);

        character_tab.add(warnText6);
        character_tab.add(characterXStepper);
        character_tab.add(characterYStepper);

        character_tab.add(warnText7);
        character_tab.add(camXStepper);
        character_tab.add(camYStepper);

        character_tab.add(saveBTN);
        
        // add tgeh shity
        uiBox.addGroup(animation_tab);
        uiBox.addGroup(character_tab);
    }

    function setCharacterData()
    {
        charData = [{
            "animations": [],
            "no_antialiasing": noAntialiasing,
            "position": [
                character.json.position[0],
                character.json.position[1]
            ],
            "healthicon": iconInput.text,
            "flip_x": flipX,
            "healthbar_colors": [
                healthColor[0],
                healthColor[1],
                healthColor[2],
            ],
            "camera_position": [
                character.json.camera_position[0],
                character.json.camera_position[1]
            ],
            "sing_duration": singDuration,
            "scale": scale
        }];

        for(i in 0...character.anims.length)
        {
            character.anims[i].offsets = [character.animOffsets[character.anims[i].anim][0], character.animOffsets[character.anims[i].anim][1]];
            charData[0].animations.push(character.anims[i]);
        }
    }

    var _file:FileReference;

    private function saveCharacterJSON()
    {
        var data:String = Json.stringify(charData[0], null, "\t");

        if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

            _file.save(data.trim(), '$curCharacter.json');
        }
    }

    function onSaveComplete(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        trace("Successfully saved character data.");
    }

    function onSaveCancel(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    function onSaveError(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        trace("Problem saving character data");
    }

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
    {
        if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
        {
            var nums:FlxUINumericStepper = cast sender;
            var wname = nums.name;
            FlxG.log.add(wname);

            switch(wname)
            {
                case 'SingDuration':
                    singDuration = FlxMath.roundDecimal(nums.value, 1);
                case 'Scale':
                    scale = FlxMath.roundDecimal(nums.value, 2);

                    character.scale.set(scale, scale);
                    character.updateHitbox();

                    character.playAnim(character.animation.curAnim.name);
                case 'Health1':
                    healthColor[0] = Std.int(nums.value);
                    var color = FlxColor.fromRGB(healthColor[0], healthColor[1], healthColor[2]);

                    healthBar.createFilledBar(color, color);
                case 'Health2':
                    healthColor[1] = Std.int(nums.value);
                    var color = FlxColor.fromRGB(healthColor[0], healthColor[1], healthColor[2]);

                    healthBar.createFilledBar(color, color);
                case 'Health3':
                    healthColor[2] = Std.int(nums.value);
                    var color = FlxColor.fromRGB(healthColor[0], healthColor[1], healthColor[2]);

                    healthBar.createFilledBar(color, color);
                case 'CharX':
                    character.json.position[0] = Std.int(nums.value);

                    character.x = stageJson.opponent[0];
                    character.x += character.json.position[0];
                case 'CharY':
                    character.json.position[1] = Std.int(nums.value);

                    character.y = stageJson.opponent[1];
                    character.y += character.json.position[1];
                case 'CamX':
                    character.json.camera_position[0] = Std.int(nums.value);
                    updatePointerPos();
                case 'CamY':
                    character.json.camera_position[1] = Std.int(nums.value);
                    updatePointerPos();
                case 'FPS':
                    character.anims[curSelected].fps = Std.int(nums.value);

					if(character.anims[curSelected].indices.length > 0)
						character.animation.addByIndices(character.anims[curSelected].anim, character.anims[curSelected].name, character.anims[curSelected].indices, '', character.anims[curSelected].fps, character.anims[curSelected].loop);
					else
						character.animation.addByPrefix(character.anims[curSelected].anim, character.anims[curSelected].name, character.anims[curSelected].fps, character.anims[curSelected].loop);
            }
        }
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

        character.antialiasing = !noAntialiasing;

        for(i in 0...icons.members.length)
        {
            icons.members[i].changeIcon(iconInput.text);

            switch(i)
            {
                case 0:
                    icons.members[i].animation.curAnim.curFrame = 0;
                case 1:
                    icons.members[i].animation.curAnim.curFrame = 1;
                case 2:
                    icons.members[i].animation.curAnim.curFrame = 2;
            }
        }

		var inputTexts:Array<FlxInputTextRTL> = [imageInput, iconInput];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
                FlxG.sound.muteKeys = [];
                FlxG.sound.volumeDownKeys = [];
                FlxG.sound.volumeUpKeys = [];
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

        var left = FlxG.keys.justPressed.A;
        var down = FlxG.keys.justPressed.S;
        var up = FlxG.keys.justPressed.W;
        var right = FlxG.keys.justPressed.D;
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

        if(FlxG.keys.justPressed.LEFT)
            changeOffset(animList[curSelected], 'x', offsetMult * -1);

        if(FlxG.keys.justPressed.RIGHT)
            changeOffset(animList[curSelected], 'x', offsetMult);

        if(FlxG.keys.justPressed.UP)
            changeOffset(animList[curSelected], 'y', offsetMult * -1);

        if(FlxG.keys.justPressed.DOWN)
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

        if(FlxG.keys.justPressed.ESCAPE)
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
            //trace(animList[curSelected]);
            character.playAnim(animList[curSelected]);
        }

        fpsStepper.value = character.anims[curSelected].fps;
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