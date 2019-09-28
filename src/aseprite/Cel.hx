package aseprite;

import ase.chunks.CelChunk;
import haxe.io.BytesInput;
import openfl.display.BitmapData;

using aseprite.Color;

/**
  A single "Cel" that holds the pixel data of a frame on a layer
**/
class Cel extends BitmapData {
  private var _chunk:CelChunk;

  public var chunk(get, never):CelChunk;

  function get_chunk():CelChunk {
    return _chunk;
  }

  public function new(sprite:AsepriteSprite, celChunk:CelChunk) {
    super(celChunk.width, celChunk.height);

    _chunk = celChunk;

    var pixelInput:BytesInput = new BytesInput(celChunk.rawData);

    // TODO: This definitely can be optimized
    lock();

    for (row in 0...celChunk.height) {
      for (col in 0...celChunk.width) {
        var pixelValue:Null<UInt> = null;

        switch (sprite.aseprite.header.colorDepth) {
          case 32:
            pixelValue = pixelInput.read(4).rgba2argb();
          case 16:
            pixelValue = pixelInput.read(2).grayscale2argb();
          case 8:
            var index:Int = pixelInput.readByte();
            pixelValue = sprite.indexed2argb(index);
        }

        if (pixelValue != null) {
          setPixel32(col, row, pixelValue);
        }
      }
    }

    unlock();
  }
}
