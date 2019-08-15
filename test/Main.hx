package;

import haxe.io.Bytes;
import flash.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;
import aseprite.AsepriteSprite;

class Main extends Sprite {
  public function new() {
    super();

    var datas = [
      Assets.getBytes('testAssets/128x128_rgba.aseprite'),
      Assets.getBytes('testAssets/grayscale.aseprite'),
      Assets.getBytes('testAssets/indexed_multi_layer.aseprite')
    ];

    var nextX:Float = 0;

    for (data in datas) {
      var sprite:AsepriteSprite = new AsepriteSprite(data);
      sprite.x = nextX;
      nextX += sprite.width;
      addChild(sprite);
    }
  }
}
