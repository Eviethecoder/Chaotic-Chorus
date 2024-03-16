
package;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxG;


class Ghostfacebutton extends FlxSpriteGroup {
  public var button:FlxSprite;
  public var answer:String;
  public var result:String;
  public static var limit:Int = 10;

  public function new(x:Int=0, y:Int=0, asset:String, value:String){
    super(x,y);
    var scale:Float = 1.0;
   
   answer = value;
    result = '';
    button = new FlxSprite(x,y).loadGraphic(Paths.image('trivia/'+ asset));
	  add(button);	
	 // button.setGraphicSize(Std.int(button.width * scale));
	  button.updateHitbox();
    }
    override public function update(elapsed:Float){
      super.update(elapsed);
      if(FlxG.mouse.overlaps(button)){           
        if(FlxG.mouse.pressed){
            remove(button);
            switch(answer){
                    
                case('true'):

                case('false'):
                result = 'death';
               


            }
         
    }
  }
    }
}