package aseprite;

import ase.chunks.CelChunk;
import haxe.io.BytesInput;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;

using aseprite.Color;

/**
  A single "Cel" that holds the pixel data of a frame on a layer
**/
class Cel extends BitmapData {
  private var _chunk:CelChunk;

  /**
    Aseprite CelChunk data
  **/
  public var chunk(get, never):CelChunk;

  function get_chunk():CelChunk {
    return _chunk;
  }

  public function new(sprite:AsepriteSprite, celChunk:CelChunk) {
    super(celChunk.width, celChunk.height, true, 0x00000000);

    _chunk = celChunk;

    var pixelInput:BytesInput = new BytesInput(celChunk.rawData);
    var pixels:ByteArray = new ByteArray(celChunk.width * celChunk.height * 4);

    for (row in 0...celChunk.height) {
      for (col in 0...celChunk.width) {
        var pixel:UInt = 0x00000000;

        switch (sprite.aseprite.header.colorDepth) {
          case 32:
            pixel = pixelInput.read(4).rgba2argb();
          case 16:
            pixel = pixelInput.read(2).grayscale2argb();
          case 8:
            pixel = sprite.indexed2argb(pixelInput.readByte());
        }

        pixels.writeUnsignedInt(pixel);
      }
    }

    pixels.position = 0;

    lock();
    setPixels(rect, pixels);
    unlock();

    pixels.clear();
  }
}
