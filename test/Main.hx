package;

import ase.chunks.ChunkType;
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
      Assets.getBytes('testAssets/tags.ase'),
      Assets.getBytes('testAssets/slices.aseprite'),
      Assets.getBytes('testAssets/pong.aseprite')
    ];

    var nextX:Float = 0;
    var nextY:Float = 0;
    var maxH:Float = 0;

    var sprites:Array<AsepriteSprite> = [];

    for (data in datas) {
      var sprite:AsepriteSprite = AsepriteSprite.fromBytes(data);
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

    var pong = sprites[sprites.length - 1];

    pong.play('pong');

    scaleX = scaleY = 2;
  }
}
