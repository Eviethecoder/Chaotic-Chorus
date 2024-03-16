package;

//this is a direct rip of pibby apocolyps preeloader. modified to work here

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
import flixel.ui.FlxBar;
import haxe.Json;
import flixel.util.FlxCollision;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception; //funi
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;


// don't ask is just for path reasons
enum PreloadType {
    atlas;
    image;
    imagealt;
    music;
    actualmusic;
    actualmusicalt;
    charXML;
    sound;
    soundalt;
}

class Loaderstate extends MusicBeatState {    
 
    var loadBar:FlxBar;

    public var isMenu:Bool = false; // for reasons

    var assetStack:Map<Dynamic, PreloadType> = [
        //Preload UI stuff
        'healthBar' => PreloadType.image,
        'timeBar' => PreloadType.image,
        

        //Icons cause why not?
       
        'icons/icon-bf' => PreloadType.imagealt,
        'icons/icon-gf' => PreloadType.imagealt,
        'icons/icon-genesis' => PreloadType.imagealt,
        'icons/icon-lifeless' => PreloadType.imagealt,
        'icons/icon-pain' => PreloadType.imagealt,
        'icons/icon-patchnote' => PreloadType.imagealt,
        'icons/icon-outcast' => PreloadType.imagealt,
        'icons/icon-s303' => PreloadType.imagealt,
        'icons/icon-snuggle' => PreloadType.imagealt,
        'icons/icon-voodoo' => PreloadType.imagealt,
        'icons/icon-shime' => PreloadType.imagealt,
       
        //Preload assets for better loading time
        'go' => PreloadType.image, 
        'ready' => PreloadType.image, 
        'set' => PreloadType.image,  
        'shit' => PreloadType.image, 
        'eventArrow' => PreloadType.image,  
        'good' => PreloadType.image,  
        'sick' => PreloadType.image,     
        
        //Preload the entire character roster ig
        'bf' => PreloadType.atlas,
        'bf-dead' => PreloadType.atlas,
        'genisischar' => PreloadType.atlas,
        'Archie' => PreloadType.atlas,
        
       
        

        //Preload character PNG and XML
        'BOYFRIEND' => PreloadType.charXML,
        'BOYFRIEND_DEAD' => PreloadType.charXML,
        'genisis' => PreloadType.charXML,
       

      

        //songs
       // 'My-Amazing-World' => PreloadType.music,
       

        // sounds
    //   // 'confirmMenu' => PreloadType.sound,
    //    // 'cancelMenu' => PreloadType.sound,
    //     'scrollMenu' => PreloadType.sound,
    //     'missnote1' => PreloadType.soundalt,
    //     'missnote2' => PreloadType.soundalt,
    //     'missnote3' => PreloadType.soundalt,
    //     'intro1' => PreloadType.soundalt,
    //     'intro2' => PreloadType.soundalt,
    //     'intro3' => PreloadType.soundalt,
    //     'introGo' => PreloadType.soundalt,
    //     'hitsound' => PreloadType.soundalt,
    //     'fnf_loss_sfx' => PreloadType.soundalt,
    //     'dialogue' => PreloadType.soundalt,

    //     // music but they not the songs
    //     'freakyMenu' => PreloadType.actualmusicalt,
        
    
    //     'breakfast' => PreloadType.actualmusic,
    //     'gameOver' => PreloadType.actualmusic,
    //     'gameOverEnd' => PreloadType.actualmusic,
    //     'tea-time' => PreloadType.actualmusic,

        // freeplay
       // 'fpmenu/arrowL' => imagealt,
       
    ];
    var maxCount:Int;

    public static var preloadedAssets:Map<String, FlxGraphic>;
    //var backgroundGroup:FlxTypedGroup<FlxSprite>;
    var bg:FlxSprite;

    public var newClass:Any;

    public function new(?e:Bool = false, ?switchClass:FlxState)
        {
            this.isMenu = e;
            this.newClass = switchClass;

            super();
        }

    override public function create() {
        super.create();

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        FlxG.camera.alpha = 0;

        maxCount = Lambda.count(assetStack);
        trace(maxCount);
        FlxG.mouse.visible = false;

        FlxG.autoPause = false;

        preloadedAssets = new Map<String, FlxGraphic>();

        bg = new FlxSprite().loadGraphic(Paths.image('loading/placeholderloader'));
		bg.screenCenter(X);
		add(bg);

        FlxTween.tween(bg, {alpha: 1}, 1.5, {ease: FlxEase.expoOut});

        // new FlxTimer().start(2, e->refresh(folderLength.length), 0);
    
        FlxTween.tween(FlxG.camera, {alpha: 1}, 0.5, {
            onComplete: function(tween:FlxTween){
                Thread.create(function(){
                    assetGenerate();
                });
            }
        });

        

        loadBar = new FlxBar(0, 960 - 20, LEFT_TO_RIGHT, 1280, 20, this,
        'storedPercentage', 0, 1);
        loadBar.alpha = 0;
        loadBar.createFilledBar(0xFF2E2E2E, FlxColor.WHITE);
        add(loadBar);

       
        FlxTween.tween(loadBar, {alpha: 1, y: 960 - 20}, 0.5, {startDelay: 0.5});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    var isRefreshing:Bool = false;

    var storedPercentage:Float = 0;

    function assetGenerate() {
        //
        var countUp:Int = 0;
        for (i in assetStack.keys()) {
            trace('calling asset $i');

            trace(assetStack[i]);
            FlxGraphic.defaultPersist = true;
            switch(assetStack[i]) {
                case PreloadType.imagealt:
                    var menuShit:FlxGraphic = FlxG.bitmap.add(Paths.image(i));
                    preloadedAssets.set(i, menuShit);
                    trace('menu asset is loaded');

                case PreloadType.image:
                    var savedGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image(i));
                    preloadedAssets.set(i, savedGraphic);
                    trace(savedGraphic + ', yeah its working');

                case PreloadType.charXML:
                    var savedGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image('characters/$i','shared' ));
                    var otherGraphic:FlxGraphic = FlxG.bitmap.add(Paths.xml('characters/$i','shared'));
                    preloadedAssets.set(i, savedGraphic);
                    preloadedAssets.set(i, otherGraphic);
                    trace(savedGraphic + ', yeah its working');
                    trace(otherGraphic + ', yeah its working too');


                case PreloadType.atlas:
                    var preloadedCharacter:Character = new Character(FlxG.width / 2, FlxG.height / 2, i);
                    preloadedCharacter.visible = false;
                    add(preloadedCharacter);
                    trace('character loaded ${preloadedCharacter.frames}');

                case PreloadType.music:
                    var savedInst:FlxGraphic = FlxG.bitmap.add(Paths.inst(i));
                    var savedVocals:FlxGraphic = FlxG.bitmap.add(Paths.voices(i));
                    preloadedAssets.set(i, savedInst);
                    preloadedAssets.set(i, savedVocals);
                    trace('loaded vocals of $savedVocals');
                    trace('loaded instrumental of $savedInst');

                case PreloadType.sound:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/preload/sounds/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded sound (default) $savedSound');

                case PreloadType.soundalt:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/shared/sounds/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded sound (shared folder) $savedSound');

                case PreloadType.actualmusic:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/shared/music/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded ACTUAL music (shared folder) $savedSound');

                case PreloadType.actualmusicalt:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/preload/music/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded music (preload folder) $savedSound');
            }
            FlxGraphic.defaultPersist = false;

           
            FlxG.stage.window.title = 'CC IS: - Loading... ${Highscore.floorDecimal(storedPercentage * 100, 2)}%';
        
            countUp++;
            storedPercentage = countUp/maxCount;
            if(countUp == maxCount)
            {

                FlxG.stage.window.title = 'CC IS: - Done!';
            }
        }

        ///*
        FlxTween.tween(FlxG.camera, {alpha: 0}, 0.5, {startDelay: 1,
            onComplete: function(tween:FlxTween){
                    MusicBeatState.switchState(isMenu ? newClass : new MainMenuState());
            }});
            }
        }