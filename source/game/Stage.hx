package game;

import states.PlayState;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.system.FlxSound;
import background.BackgroundGirls;
import background.BackgroundDancer;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

typedef StageData = {
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;
	var boyfriend:Array<Float>;
	var girlfriend:Array<Float>;
	var opponent:Array<Float>;
}

class Stage extends FlxGroup
{
    public var curStage:String = "stage";

    // philly
	public var phillyCityLights:FlxTypedGroup<FlxSprite>;
	public var phillyTrain:FlxSprite;
	public var trainSound:FlxSound;
    public var curLight:Int = 0;
    public var trainMoving:Bool = false;
	public var trainFrameTiming:Float = 0;

	public var trainCars:Int = 8;
	public var trainFinishing:Bool = false;
	public var trainCooldown:Int = 0;

    public var startedMoving:Bool = false;

    // limo
	public var limo:FlxSprite;
	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
    public var fastCarCanDrive:Bool = true;
	public var fastCar:FlxSprite;

    // spooky
    public var halloweenBG:FlxSprite;
    public var lightningStrikeBeat:Int = 0;
	public var lightningOffset:Int = 8;

    // mall
	public var upperBoppers:FlxSprite;
	public var bottomBoppers:FlxSprite;
	public var santa:FlxSprite;

    // week 6
	public var bgGirls:BackgroundGirls;
    // ^^ WILL REMOVE IF I BOTHER TO UNHARDCODE BASE GAME STAGES LOL

    public var foregroundSprites:FlxGroup = new FlxGroup();
    public var infrontOfGFSprites:FlxGroup = new FlxGroup();

    public function addObject(object:Dynamic, ?layer:String = "back")
    {
        switch(layer)
        {
            case 'back':
                add(object);
            case 'gf' | 'middle':
                infrontOfGFSprites.add(object);
            case 'front':
                foregroundSprites.add(object);
        }
            
    }

    public function changeStage(?stage:String = "stage")
    {
        curStage = stage;

        switch(stage)
		{
            default:
            {
                // death
            }  
			case 'spooky': 
			{
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = Paths.getSparrowAtlas('halloween_bg', 'week2');
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				addObject(halloweenBG);
			}
			case 'philly': 
			{
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
				bg.scrollFactor.set(0.1, 0.1);
				addObject(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				addObject(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				addObject(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
				addObject(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
				addObject(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
				addObject(street);
			}
			case 'limo':
			{
				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
				skyBG.scrollFactor.set(0.1, 0.1);
				addObject(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				addObject(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				addObject(grpLimoDancers);

				for (i in 0...5)
				{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
				}

				var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
				overlayShit.alpha = 0.5;
				// addObject(overlayShit);

				var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
				addObject(limo, "gf");
                addObject(fastCar, "front");

                resetFastCar();
			}
			case 'mall':
			{
				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				addObject(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				addObject(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				addObject(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				addObject(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				addObject(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				addObject(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				addObject(santa);
			}
			case 'mallEvil':
			{
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				addObject(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				addObject(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
				evilSnow.antialiasing = true;
				addObject(evilSnow);
			}
			case 'school':
			{
				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
				bgSky.scrollFactor.set(0.1, 0.1);
				addObject(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				addObject(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				addObject(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				addObject(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				addObject(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				addObject(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (PlayState.SONG.song.toLowerCase() == 'roses')
					bgGirls.getScared();

				bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
				bgGirls.updateHitbox();
				addObject(bgGirls);
			}
			case 'schoolEvil':
			{
				var bg:FlxSprite = new FlxSprite(400, 200);
				bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				addObject(bg);
			}
			case 'stage':
			{
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'shared'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				addObject(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'shared'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				addObject(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', 'shared'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				addObject(stageCurtains);
			}
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}
    }

    public function beatHit(curBeat)
    {
		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
    }

    public function stepHit(curStep)
    {
        // somethin goes here idk what but yea
    }

	function resetFastCar():Void
    {
        fastCar.x = -12600;
        fastCar.y = FlxG.random.int(140, 250);
        fastCar.velocity.x = 0;
        fastCarCanDrive = true;
    }

    function fastCarDrive()
    {
        FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

        fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
        fastCarCanDrive = false;
        new FlxTimer().start(2, function(tmr:FlxTimer)
        {
            resetFastCar();
        });
    }

	function trainStart():Void
    {
        trainMoving = true;
        if (!trainSound.playing)
            trainSound.play(true);
    }

    function updateTrainPos():Void
    {
        if (trainSound.time >= 4700)
        {
            startedMoving = true;
            PlayState.instance.gf.playAnim('hairBlow');
        }

        if (startedMoving)
        {
            phillyTrain.x -= 400;

            if (phillyTrain.x < -2000 && !trainFinishing)
            {
                phillyTrain.x = -1150;
                trainCars -= 1;

                if (trainCars <= 0)
                    trainFinishing = true;
            }

            if (phillyTrain.x < -4000 && trainFinishing)
                trainReset();
        }
    }

    function trainReset():Void
    {
        PlayState.instance.gf.playAnim('hairFall');
        phillyTrain.x = FlxG.width + 200;
        trainMoving = false;
        // trainSound.stop();
        // trainSound.time = 0;
        trainCars = 8;
        trainFinishing = false;
        startedMoving = false;
    }

    function lightningStrikeShit():Void
    {
        FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
        halloweenBG.animation.play('lightning');

        lightningStrikeBeat = PlayState.instance.curBeat;
        lightningOffset = FlxG.random.int(8, 24);

        PlayState.instance.boyfriend.playAnim('scared', true);
        PlayState.instance.gf.playAnim('scared', true);
    }
}