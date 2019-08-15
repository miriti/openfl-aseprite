package;

import haxe.io.Bytes;
import flash.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;
import aseprite.AsepriteSprite;

class Main extends Sprite {
  public function new() {
    super();

    var bytes:Bytes = Assets.getBytes('testAssets/128x128_rgba.aseprite');
    var grayscale:Bytes = Assets.getBytes('testAssets/grayscale.aseprite');

    addChild(new AsepriteSprite(grayscale));
  }
}
