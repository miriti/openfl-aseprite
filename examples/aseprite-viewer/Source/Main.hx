package;

import aseprite.AsepriteSprite;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

class Main extends Sprite {
  var sprite:AsepriteSprite;

  public function new() {
    super();

    scaleX = scaleY = 2;

    sprite = AsepriteSprite.fromBytes(Assets.getBytes('assets/example.aseprite'));
    sprite.x = (400 - sprite.width) / 2;
    sprite.play('walking');
    addChild(sprite);

    var nextButtonX:Float = 10;
    for (tag in sprite.tags) {
      var newButton = createButton(tag.name, () -> {
        sprite.currentTag = tag.name;
      });
      newButton.x = nextButtonX;
      newButton.y = 5;
      nextButtonX += newButton.width + 10;
      addChild(newButton);
    }

    var playButton:Sprite;
    var pauseButton:Sprite;

    playButton = createButton('Play', () -> {
      sprite.play();
      playButton.visible = false;
      pauseButton.visible = true;
    });
    playButton.x = 5;
    playButton.y = 300 - playButton.height - 5;
    playButton.visible = false;
    addChild(playButton);

    pauseButton = createButton('Pause', () -> {
      sprite.pause();
      playButton.visible = true;
      pauseButton.visible = false;
    });
    pauseButton.x = 5;
    pauseButton.y = 300 - pauseButton.height - 5;
    addChild(pauseButton);
  }

  function createButton(label:String, action:Void->Void) {
    var button = new Sprite();

    var textField = new TextField();
    textField.text = label;
    textField.selectable = false;
    textField.setTextFormat(new TextFormat('sans', 10));
    textField.autoSize = TextFieldAutoSize.LEFT;

    button.graphics.beginFill(0xcccccc);
    button.graphics.drawRect(0, 0, textField.width + 20, textField.height + 20);
    button.graphics.endFill();

    textField.x = (button.width - textField.width) / 2;
    textField.y = (button.height - textField.height) / 2;
    button.addChild(textField);

    button.buttonMode = true;
    button.addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> {
      action();
    });

    return button;
  }
}
