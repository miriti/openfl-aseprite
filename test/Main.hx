package;

import aseprite.AsepriteSprite;
import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite {
  public function new() {
    super();

    var datas = [
      Assets.getBytes('testAssets/128x128_rgba.aseprite'),
      Assets.getBytes('testAssets/grayscale.aseprite'),
      Assets.getBytes('testAssets/indexed_multi_layer.aseprite'),
      Assets.getBytes('testAssets/animation.aseprite'),
      Assets.getBytes('testAssets/anim_linked_cels.aseprite'),
      Assets.getBytes('testAssets/tags.ase')
    ];

    var nextX:Float = 0;
    var nextY:Float = 0;
    var maxH:Float = 0;

    for (data in datas) {
      var sprite:AsepriteSprite = AsepriteSprite.fromBytes(data, true, 0xcccccc);
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
    }

    scaleX = scaleY = 2;
  }
}
