package aseprite;

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
            bitmapData.setPixel32(col, row, pixelInput.readInt32());
          case 16:
            var pixel:Bytes = pixelInput.read(2);
            var rgba:Bytes = Bytes.alloc(4);
            rgba.set(0, pixel.get(0));
            rgba.set(1, pixel.get(0));
            rgba.set(2, pixel.get(0));
            rgba.set(3, pixel.get(1));
            bitmapData.setPixel32(col, row, rgba.getInt32(0));
          case 8:
            trace(8);
        }
      }
    }
    bitmapData.unlock();

    addChild(new Bitmap(bitmapData));
  }
}
