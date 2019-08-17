package aseprite;

import haxe.io.Bytes;

class Color {
  public static function rgba2argb(rgba:Bytes):UInt {
    var argb:Bytes = Bytes.alloc(4);
    argb.set(0, rgba.get(2));
    argb.set(1, rgba.get(1));
    argb.set(2, rgba.get(0));
    argb.set(3, rgba.get(3));
    return argb.getInt32(0);
  }

  public static function grayscale2argb(bytePair:Bytes):UInt {
    var rgba:Bytes = Bytes.alloc(4);
    rgba.set(0, bytePair.get(0));
    rgba.set(1, bytePair.get(0));
    rgba.set(2, bytePair.get(0));
    rgba.set(3, bytePair.get(1));
    return rgba.getInt32(0);
  }

  public static function indexed2argb(sprite:AsepriteSprite,
      index:Int):Null<UInt> {
    return
      index == sprite.aseprite.header.paletteEntry ? 0x00000000 : sprite.palette.entries[index];
  }
}
