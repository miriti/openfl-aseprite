package;

import aseprite.Aseprite;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class Main extends Sprite {
  public function new() {
    super();

    var datas = [
      Assets.getBytes('testAssets/128x128_rgba.aseprite'),
      Assets.getBytes('testAssets/grayscale.aseprite'),
      Assets.getBytes('testAssets/indexed_multi_layer.aseprite'),
      Assets.getBytes('testAssets/animation.aseprite'),
      Assets.getBytes('testAssets/anim_linked_cels.aseprite'),
      Assets.getBytes('testAssets/tags.ase'),
      Assets.getBytes('testAssets/slices.aseprite'),
      Assets.getBytes('testAssets/slices2.aseprite'),
      Assets.getBytes('testAssets/pong.aseprite')
    ];

    var nextX:Float = 0;
    var nextY:Float = 0;
    var maxH:Float = 0;

    var sprites:Array<Aseprite> = [];

    for (data in datas) {
      var sprite:Aseprite = Aseprite.fromBytes(data);
      maxH = Math.max(maxH, sprite.height);

      if (nextX + sprite.width > stage.stageWidth / 2) {
        nextX = 0;
        nextY += maxH;
        maxH = 0;
      }
      sprite.x = nextX;
      sprite.y = nextY;
      nextX += sprite.width;
      addChild(sprite);
      sprites.push(sprite);
      sprite.play();
    }

    var slices2 = sprites[sprites.length - 2];

    for (slice in slices2.slices) {
      var sliceSprite = slices2.spawn(slice.name);
      sliceSprite.x = slices2.x + slice.chunk.sliceKeys[0].xOrigin;
      sliceSprite.y = slices2.y + slice.chunk.sliceKeys[0].yOrigin;
      sliceSprite.buttonMode = true;
      sliceSprite.addEventListener(MouseEvent.MOUSE_DOWN,
        (event:MouseEvent) -> {
          sliceSprite.startDrag();
        });
      sliceSprite.addEventListener(MouseEvent.MOUSE_UP, (event:MouseEvent) -> {
        sliceSprite.stopDrag();
      });
      sliceSprite.play();
      addChild(sliceSprite);
    }

    var pong = sprites[sprites.length - 1];
    pong.play('pong');

    scaleX = scaleY = 2;
  }
}
