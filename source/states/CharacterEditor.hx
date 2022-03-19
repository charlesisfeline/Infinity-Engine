package states;

import flixel.addons.ui.FlxUIInputText;
import lime.system.Clipboard;
import flixel.FlxObject;
import game.CharacterPart;
import game.Character;
import game.Stage;
import flixel.FlxG;

using StringTools;

class CharacterEditor extends MusicBeatState
{
    var curCharacter:String = "dad";

    var flipX:Bool = false;
    var isPlayer:Bool = false;

    var camFollow:FlxObject;

    var stage:Stage;
    var stageJson:StageData;

    var character:CharacterPart;

    var cameraZoom:Float = 1;

    override public function create()
    {
        super.create();

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
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		var inputTexts:Array<FlxUIInputText> = [];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
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

        var left = FlxG.keys.justPressed.LEFT;
        var down = FlxG.keys.justPressed.DOWN;
        var up = FlxG.keys.justPressed.UP;
        var right = FlxG.keys.justPressed.RIGHT;
        var shiftP = FlxG.keys.pressed.SHIFT;

        var offsetMultiplier:Float = 0;

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
            FlxG.switchState(new MainMenuState());
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