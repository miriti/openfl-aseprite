package aseprite;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import ase.chunks.CelChunk;
import flash.display.Sprite;

class Cel extends Sprite {
  public function new(sprite:AsepriteSprite, celChunk:CelChunk) {
    super();

    var bitmapData:BitmapData = new BitmapData(celChunk.width, celChunk.height);
    var pixelInput:BytesInput = new BytesInput(celChunk.rawData);

    bitmapData.lock();
    for (row in 0...celChunk.height) {
      for (col in 0...celChunk.width) {
        switch (sprite.asepriteFile.header.colorDepth) {
          case 32:
            bitmapData.setPixel32(col, row, Color.rgba2argb(pixelInput.read(4)));
          case 16:
            bitmapData.setPixel32(col, row, Color.grayscale2argb(pixelInput.read(2)));
          case 8:
            var index:Int = pixelInput.readByte();
            var color:Null<Int32> = Color.indexed2argb(sprite, index);
            if (color != null) {
              bitmapData.setPixel32(col, row, color);
            }
        }
      }
    }
    bitmapData.unlock();

    addChild(new Bitmap(bitmapData));

    x = celChunk.xPosition;
    y = celChunk.yPosition;
  }
}
