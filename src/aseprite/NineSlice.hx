package aseprite;

import ase.chunks.SliceChunk.SliceKey;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;

typedef NineSliceSlices = Array<Array<BitmapData>>;

class NineSlice extends Sprite {
  public var slices(default, set):NineSliceSlices;

  function set_slices(value:NineSliceSlices):NineSliceSlices {
    slices = value;

    graphics.beginBitmapFill(slices[0][0]);
    graphics.drawRect(0, 0, slices[0][0].width, slices[0][0].height);
    graphics.endFill();

    return slices;
  }

  public function new(slices:NineSliceSlices) {
    super();

    this.slices = slices;
  }

  public static function generate(bitmapData:BitmapData,
      sliceKey:SliceKey):NineSliceSlices {
    var result:NineSliceSlices = [[null, null, null], [null, null, null], [null, null, null]];

    var cols:Array<Array<Int>> = [
      [0, sliceKey.xCenter],
      [sliceKey.xCenter, sliceKey.centerWidth],
      [
        sliceKey.xCenter + sliceKey.centerWidth,
        bitmapData.width - (sliceKey.xCenter + sliceKey.centerWidth)
      ]
    ];

    var rows:Array<Array<Int>> = [
      [0, sliceKey.yCenter],
      [sliceKey.yCenter, sliceKey.centerHeight],
      [
        sliceKey.yCenter + sliceKey.centerHeight,
        bitmapData.height - (sliceKey.yCenter + sliceKey.centerHeight)
      ]
    ];

    for (row in 0...3) {
      for (col in 0...3) {
        var slice = new BitmapData(cols[col][1], rows[row][1]);
        slice.copyPixels(bitmapData,
          new Rectangle(cols[col][0], rows[row][0], cols[col][1], rows[row][1]),
          new Point(0, 0));
        result[row][col] = slice;
      }
    }

    return result;
  }
}
