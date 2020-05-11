package;

import aseprite.Aseprite;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

class Main extends Sprite {
  var batSprite:Aseprite;

  var batsLayer:Sprite = new Sprite();

  var bats:Array<Bat> = [];

  var batsNumber:TextField;

  var mouseDown:Bool;

  var lastTime:Int;

  public function new() {
    super();

    batSprite = Aseprite.fromBytes(Assets.getBytes('Assets/bat.aseprite'));

    graphics.beginFill(0xcccccc);
    graphics.drawRect(0, 0, 320, 240);
    graphics.endFill();

    addChild(batsLayer);

    batsNumber = new TextField();
    batsNumber.setTextFormat(new TextFormat('_sans', 12, 0xff0000));
    batsNumber.autoSize = TextFieldAutoSize.LEFT;
    addChild(batsNumber);

    addChild(new FPS(0, 15, 0xff0000));
    var hint = new TextField();
    hint.setTextFormat(new TextFormat('_sans', 12, 0xff0000));
    hint.autoSize = TextFieldAutoSize.LEFT;
    hint.text = "Click to add bats";
    hint.x = 0;
    hint.y = 30;
    addChild(hint);

    updateBatsNumber();

    scaleX = scaleY = 2;

    addEventListener(Event.ADDED_TO_STAGE,
      (event:Event) -> lastTime = Lib.getTimer());
    addEventListener(MouseEvent.MOUSE_DOWN,
      (event:MouseEvent) -> mouseDown = true);
    addEventListener(MouseEvent.MOUSE_UP,
      (event:MouseEvent) -> mouseDown = false);
    addEventListener(Event.ENTER_FRAME, onEnterFrame);
  }

  function updateBatsNumber() {
    batsNumber.text = 'Bats number: ${bats.length}';
  }

  function onEnterFrame(event:Event) {
    var currentTime = Lib.getTimer();
    var timeDelta:Int = currentTime - lastTime;
    lastTime = currentTime;

    for (bat in bats) {
      bat.update(timeDelta);
    }

    if (mouseDown) {
      var newBat = new Bat(batSprite.spawn(false));
      newBat.x = mouseX + (-1 + Math.random() * 2) * 32;
      newBat.y = mouseY + (-1 + Math.random() * 2) * 32;
      batsLayer.addChild(newBat);
      bats.push(newBat);
      updateBatsNumber();
    }
  }
}
