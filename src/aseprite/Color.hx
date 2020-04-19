package aseprite;

import haxe.io.Bytes;

/**
  Static functions for color manipulations
**/
class Color {
  /**
    Converts an 0xRRGGBBAA value to a 0xAARRGGBB one

    Can it be optimized by using bit shifting?
  **/
  public static function rgba2argb(rgba:Bytes):UInt {
    var argb:Bytes = Bytes.alloc(4);
    argb.set(0, rgba.get(2));
    argb.set(1, rgba.get(1));
    argb.set(2, rgba.get(0));
    argb.set(3, rgba.get(3));
    return argb.getInt32(0);
  }

  /**
    Converts a 16 bit (whiteness/alpha) color value of 0xWWAA
    to a 32 bit RGBA value 0xRRGGBBAA
  **/
  public static function grayscale2argb(bytePair:Bytes):UInt {
    var rgba:Bytes = Bytes.alloc(4);
    rgba.set(0, bytePair.get(0));
    rgba.set(1, bytePair.get(0));
    rgba.set(2, bytePair.get(0));
    rgba.set(3, bytePair.get(1));
    return rgba.getInt32(0);
  }

  /**
    Returns a 32 bit color value from the pallete
    or 0x00000000 if no such index in the palette
  **/
  public static function indexed2argb(sprite:AsepriteSprite,
      index:Int):Null<UInt> {
    return
      index == sprite.aseprite.header.paletteEntry ? 0x00000000 : (sprite.palette.entries.exists(index) ? sprite.palette.entries[index] : 0x00000000);
  }
}
