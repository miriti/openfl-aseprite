package aseprite;

import ase.chunks.CelChunk;
import ase.chunks.CelType;
import ase.chunks.ChunkType;
import ase.chunks.LayerChunk;
import ase.chunks.LayerFlags;
import aseprite.Cel;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.Matrix;

typedef LayerDef = {
  layerChunk:LayerChunk,
  cel:Cel
};

/**
  A single frame in the animation
**/
class Frame extends Bitmap {
  public var duration(get, never):Int;

  function get_duration():Int {
    return _frame.header.duration;
  }

  private var _layers:Array<LayerDef> = [];

  public var layers(get, never):Array<LayerDef>;

  function get_layers():Array<LayerDef> {
    return _layers;
  }

  public var startTime:Int;

  private var _frame:ase.Frame;

  public function new(sprite:AsepriteSprite, frame:ase.Frame) {
    _frame = frame;

    var bitmapData:BitmapData = new BitmapData(sprite.aseprite.header.width, sprite.aseprite.header.height);

    for (layer in sprite.layers) {
      _layers.push({
        layerChunk: layer,
        cel: null
      });
    }

    for (chunk in frame.chunks) {
      if (chunk.header.type == ChunkType.CEL) {
        var cel:CelChunk = cast chunk;

        if (cel.celType == CelType.LINKED) {
          _layers[cel.layerIndex].cel = sprite.frames[cel.linkedFrame].layers[cel.layerIndex].cel;
        } else {
          _layers[cel.layerIndex].cel = new Cel(sprite, cel);
        }
      }

      for (layer in _layers) {
        if (layer.cel != null && (layer.layerChunk.flags & LayerFlags.VISIBLE != 0)) {
          // TODO: Implement all the blendModes
          var blendModes:Array<BlendMode> = [
            NORMAL, // 0 - Normal
            MULTIPLY, // 1 - Multiply
            SCREEN, // 2 - Scren
            OVERLAY, // 3 - Overlay
            DARKEN, // 4 - Darken
            LIGHTEN, // 5 -Lighten
            NORMAL, // 6 - Color Dodge - NOT IMPLEMENTED
            NORMAL, // 7 - Color Burn - NOT IMPLEMENTED
            HARDLIGHT, // 8 - Hard Light
            NORMAL, // 9 - Soft Light - NOT IMPLEMENTED
            DIFFERENCE, // 10 - Difference
            ERASE, // 11 - Exclusion - Not sure about that
            NORMAL, // 12 - Hue - NOT IMPLEMENTED
            NORMAL, // 13 - Saturation - NOT IMPLEMENTED
            NORMAL, // 14 - Color - NOT IMPLEMENTED
            NORMAL, // 15 - Luminosity - NOT IMPLEMENTED
            ADD, // 16 - Addition
            SUBTRACT, // 17 - Subtract
            NORMAL // 18 - Divide - NOT IMPLEMENTED
          ];
          var blendMode:BlendMode = blendModes[layer.layerChunk.blendMode];

          var matrix:Matrix = new Matrix();
          matrix.translate(layer.cel.chunk.xPosition, layer.cel.chunk.yPosition);
          bitmapData.draw(layer.cel, matrix, null, blendMode);
        }
      }

      super(bitmapData);
    }
  }
}
