package;

import openfl.display.FPS;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.events.Event;
import aseprite.AsepriteSprite;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class Main extends Sprite {
  var batSprite:AsepriteSprite;

  var batsLayer:Sprite = new Sprite();

  var bats:Array<Bat> = [];

  var batsNumber:TextField;

  var mouseDown:Bool;

  public function new() {
    super();

    batSprite = AsepriteSprite.fromBytes(Assets.getBytes('Assets/bat.aseprite'));

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

    addEventListener(MouseEvent.MOUSE_DOWN,
      (event:MouseEvent) -> mouseDown = true);
    addEventListener(MouseEvent.MOUSE_UP,
      (event:MouseEvent) -> mouseDown = false);
    addEventListener(Event.ENTER_FRAME, onEnterFrame);
  }

  function updateBatsNumber() {
    batsNumber.text = 'Bets number: ${bats.length}';
  }

  function onEnterFrame(event:Event) {
    if (mouseDown) {
      var newBat = new Bat(batSprite.spawn());
      newBat.x = mouseX + (-1 + Math.random() * 2) * 32;
      newBat.y = mouseY + (-1 + Math.random() * 2) * 32;
      batsLayer.addChild(newBat);
      bats.push(newBat);
      updateBatsNumber();
    }
  }
}
