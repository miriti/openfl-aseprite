package aseprite;

import ase.chunks.SliceChunk.SliceKey;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;

typedef NineSliceSlices = Array<Array<BitmapData>>;

/**
  9Slice utilities
**/
class NineSlice extends Sprite {
  /**
    Generate 9Slices from a `BitmapData`

    @param bitmapData BitmapData
    @param sliceKey   9Slice Slice Key
  **/
  public static function generate(bitmapData:BitmapData,
      sliceKey:SliceKey):NineSliceSlices {
    var result:NineSliceSlices = [for (_ in 0...3) [for (_ in 0...3) null]];

    var xs = [
      sliceKey.xOrigin,
      sliceKey.xOrigin + sliceKey.xCenter,
      sliceKey.xOrigin + sliceKey.xCenter + sliceKey.centerWidth
    ];

    var ys = [
      sliceKey.yOrigin,
      sliceKey.yOrigin + sliceKey.yCenter,
      sliceKey.yOrigin + sliceKey.yCenter + sliceKey.centerHeight
    ];

    var widths = [
      sliceKey.xCenter,
      sliceKey.centerWidth,
      sliceKey.width - (sliceKey.xCenter + sliceKey.centerWidth)
    ];
    var heights = [
      sliceKey.yCenter,
      sliceKey.centerHeight,
      sliceKey.height - (sliceKey.yCenter + sliceKey.centerHeight)
    ];

    var zeroPoint = new Point(0, 0);

    for (row in 0...3) {
      for (col in 0...3) {
        var slice = new BitmapData(widths[col], heights[row]);
        slice.copyPixels(bitmapData,
          new Rectangle(xs[col], ys[row], widths[col], heights[row]),
          zeroPoint);
        result[row][col] = slice;
      }
    }

    return result;
  }
}
