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

@:dox(hide)
typedef LayerDef = {
  layerChunk:LayerChunk,
  cel:Cel
};

/**
  Holds information regarding a single frame of the animation
**/
class Frame extends Bitmap {
  public var duration(get, never):Int;

  function get_duration():Int {
    return _frame.header.duration;
  }

  private var _frame:ase.Frame;

  public var frame(get, never):ase.Frame;

  function get_frame():ase.Frame {
    return _frame;
  }

  private var _layers:Array<LayerDef> = [];

  public var layers(get, never):Array<LayerDef>;

  function get_layers():Array<LayerDef> {
    return _layers;
  }

  private var _layersMap:Map<String, LayerDef> = [];

  public var layersMap(get, never):Map<String, LayerDef>;

  function get_layersMap():Map<String, LayerDef> {
    return _layersMap;
  }

  public var startTime:Int;

  var _tags:Array<String> = [];

  public var tags(get, never):Array<String>;

  function get_tags():Array<String> {
    return _tags;
  }

  private var _bitmap:Bitmap;

  public function new(sprite:AsepriteSprite, frame:ase.Frame) {
    super(new BitmapData(sprite.aseprite.header.width,
      sprite.aseprite.header.height, true, 0x00000000));

    _frame = frame;

    for (layer in sprite.layers) {
      var layerDef = {
        layerChunk: layer,
        cel: null
      };
      _layers.push(layerDef);
      _layersMap[layer.name] = layerDef;
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
        if (layer.cel != null
          && (layer.layerChunk.flags & LayerFlags.VISIBLE != 0)) {
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
          matrix.translate(layer.cel.chunk.xPosition,
            layer.cel.chunk.yPosition);
          bitmapData.lock();
          bitmapData.draw(layer.cel, matrix, null, blendMode);
          bitmapData.unlock();
        }
      }
    }
  }
}
