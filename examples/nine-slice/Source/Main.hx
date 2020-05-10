package;

import aseprite.Aseprite;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

using Std;

class Main extends Sprite {
  var buttonSprite:Aseprite;

  var button:Aseprite;

  var buttonText:TextField;

  public function new() {
    super();

    scaleX = scaleY = 4;

    buttonSprite = Aseprite.fromBytes(Assets.getBytes('Assets/button.aseprite'));

    button = buttonSprite.spawn('Slice 1', 60, 40);
    button.play();
    addChild(button);

    buttonText = new TextField();
    buttonText.text = 'Button';
    buttonText.setTextFormat(new TextFormat(Assets.getFont('Assets/hardpixel.otf')
      .fontName, 16, 0xffffff));
    buttonText.selectable = false;
    buttonText.autoSize = TextFieldAutoSize.LEFT;
    buttonText.x = button.x + (button.width - buttonText.width) / 2;
    buttonText.y = button.y + (button.height - buttonText.height) / 2;
    addChild(buttonText);

    var handle = new Sprite();
    handle.graphics.beginFill(0x0);
    handle.graphics.drawRect(1, 1, 5, 5);
    handle.graphics.beginFill(0xffffff);
    handle.graphics.drawRect(0, 0, 5, 5);
    handle.graphics.endFill();

    handle.buttonMode = true;

    handle.x = button.width;
    handle.y = button.height;

    handle.addEventListener(MouseEvent.MOUSE_DOWN, (event:MouseEvent) -> {
      handle.startDrag();
    });
    handle.addEventListener(MouseEvent.MOUSE_UP, (event:MouseEvent) -> {
      handle.stopDrag();
    });
    handle.addEventListener(MouseEvent.MOUSE_MOVE, (event:MouseEvent) -> {
      button.resize((handle.x - button.x).int(), (handle.y - button.y).int());
      buttonText.x = button.x + (button.width - buttonText.width) / 2;
      buttonText.y = button.y + (button.height - buttonText.height) / 2;
    });

    addChild(handle);
  }
}
