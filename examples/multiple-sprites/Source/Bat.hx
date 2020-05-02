import openfl.Lib;
import openfl.events.Event;
import aseprite.AsepriteSprite;
import openfl.display.Sprite;

class Bat extends Sprite {
  var state(default, set):String;

  function set_state(newState:String):String {
    if (state != newState) {
      state = newState;
      sprite.play(state);
    }

    return state;
  }

  var sprite:AsepriteSprite;

  var time:Int;

  public function new(sprite:AsepriteSprite) {
    super();
    this.sprite = sprite;
    sprite.x = -sprite.width / 2;
    sprite.y = -sprite.height / 2;
    addChild(sprite);

    addEventListener(Event.ENTER_FRAME, onEnterFrame);

    randomState();
  }

  function randomState() {
    var states = ['front', 'left', 'right', 'back'];

    state = states[Math.floor(Math.random() * states.length)];
    time = Lib.getTimer();
  }

  function onEnterFrame(event:Event) {
    switch (state) {
      case 'front':
        y += 1;
        if (y >= 240)
          state = 'back';
      case 'left':
        x -= 1;
        if (x <= 0)
          state = 'right';
      case 'right':
        x += 1;
        if (x > 320)
          state = 'left';
      case 'back':
        y -= 1;
        if (y <= 0)
          state = 'front';
    }

    if (Lib.getTimer() - time >= 3000) {
      randomState();
    }
  }
}
