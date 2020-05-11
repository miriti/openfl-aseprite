package aseprite;

import ase.chunks.CelChunk;
import ase.chunks.CelType;
import ase.chunks.ChunkType;
import ase.chunks.LayerChunk;
import ase.chunks.LayerFlags;
import aseprite.Cel;
import aseprite.NineSlice.NineSliceSlices;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:dox(hide)
typedef LayerDef = {
  layerChunk:LayerChunk,
  cel:Cel
};

/**
  Holds information regarding a single frame of the animation
**/
class Frame {
  /**
    Frame's bitmap data
  **/
  public var bitmapData:BitmapData;

  /**
    Duration of the frame in milliseconds
  **/
  public var duration(get, never):Int;

  function get_duration():Int {
    return _frame.header.duration;
  }

  private var _frame:ase.Frame;

  /**
    Raw frame data parsed from the file
  **/
  public var frame(get, never):ase.Frame;

  function get_frame():ase.Frame {
    return _frame;
  }

  private var _index:Int;

  /**
    Frame index in the sprite
  **/
  public var index(get, never):Int;

  function get_index():Int
    return _index;

  private var _layers:Array<LayerDef> = [];

  /**
    Sprite layers
  **/
  public var layers(get, never):Array<LayerDef>;

  function get_layers():Array<LayerDef> {
    return _layers;
  }

  private var _layersMap:Map<String, LayerDef> = [];

  /**
    Map of the sprite layers keyed by their names
  **/
  public var layersMap(get, never):Map<String, LayerDef>;

  function get_layersMap():Map<String, LayerDef> {
    return _layersMap;
  }

  var nineSlices:NineSliceSlices;

  var _tags:Array<String> = [];

  /**
    Array of tags this frame is tagged with
  **/
  public var tags(get, never):Array<String>;

  function get_tags():Array<String> {
    return _tags;
  }

  var _renderWidth:Int;
  var _renderHeight:Int;

  /**
    Frame constructor

    @param index
    @param frameBitmapData
    @param nineSlices
    @param renderWidth
    @param renderHeight
    @param sprite
    @param frame
  **/
  public function new(index:Int, ?frameBitmapData:BitmapData,
      ?nineSlices:NineSliceSlices, ?renderWidth:Int, ?renderHeight:Int,
      ?sprite:Aseprite, ?frame:ase.Frame) {
    if (frameBitmapData != null) {
      bitmapData = frameBitmapData;
    } else {
      if (nineSlices != null) {
        this.nineSlices = nineSlices;

        renderWidth = renderWidth == null ? nineSlices[0][0].width
          + nineSlices[0][1].width
          + nineSlices[0][2].width : renderWidth;

        renderHeight = renderHeight == null ? nineSlices[0][0].height
          + nineSlices[1][0].height
          + nineSlices[2][0].height : renderHeight;

        render9Slice(renderWidth, renderHeight);
      } else {
        bitmapData = new BitmapData(sprite.ase.header.width,
          sprite.ase.header.height, true, 0x00000000);

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
  }

  /**
    Creates a copy of the frame reusing the resources

    @param slicel       Slice to cut from the original sprite
    @param spriteWidth  Width of the resulting frame
    @param spriteHeight Height of the resulting frame
  **/
  public function copy(?slice:Slice, ?spriteWidth:Int,
      ?spriteHeight:Int):Frame {
    var copyFrame:Frame;

    if (slice != null) {
      if (slice.chunk.has9Slices) {
        var nineSlice:NineSliceSlices = slice.nineSliceCache[index];

        if (nineSlice == null) {
          nineSlice = NineSlice.generate(bitmapData, slice.firstKey);
          slice.nineSliceCache[index] = nineSlice;
        }

        copyFrame = new Frame(index, nineSlice, spriteWidth, spriteHeight);
      } else {
        var sliceBitmapData:BitmapData = slice.bitmapCache[index];

        if (sliceBitmapData == null) {
          sliceBitmapData = new BitmapData(slice.chunk.sliceKeys[0].width,
            slice.chunk.sliceKeys[0].height);
          sliceBitmapData.copyPixels(bitmapData,
            new Rectangle(slice.chunk.sliceKeys[0].xOrigin,
              slice.chunk.sliceKeys[0].yOrigin,
              slice.chunk.sliceKeys[0].width, slice.chunk.sliceKeys[0].height),
            new Point(0, 0));

          slice.bitmapCache[index] = sliceBitmapData;
        }
        copyFrame = new Frame(index, sliceBitmapData);
      }
    } else {
      copyFrame = new Frame(index, bitmapData);
    }

    copyFrame._frame = _frame;
    copyFrame._layers = _layers;
    copyFrame._layersMap = _layersMap;
    copyFrame._tags = _tags;

    return copyFrame;
  }

  function render9Slice(renderWidth:Int, renderHeight:Int) {
    if (!(renderWidth != _renderWidth || renderHeight != _renderHeight)) {
      return;
    }

    _renderWidth = renderWidth;
    _renderHeight = renderHeight;

    if (bitmapData != null) {
      bitmapData.dispose();
      bitmapData = null;
    }

    var render = new Sprite();

    var centerWidth = renderWidth
      - (nineSlices[0][0].width + nineSlices[0][2].width);
    var centerHeight = renderHeight
      - (nineSlices[0][0].height + nineSlices[2][0].height);

    var centerX = nineSlices[0][0].width;
    var centerY = nineSlices[0][0].height;

    var xs = [0, centerX, centerX + centerWidth];
    var ys = [0, centerY, centerY + centerHeight];

    var widths:Array<Int> = [nineSlices[0][0].width, centerWidth, nineSlices[0][2].width];
    var heights:Array<Int> = [nineSlices[0][0].height, centerHeight, nineSlices[2][0].height];

    for (row in 0...3) {
      for (col in 0...3) {
        var sliceRender = new Shape();
        sliceRender.graphics.beginBitmapFill(nineSlices[row][col]);
        sliceRender.graphics.drawRect(0, 0, widths[col], heights[row]);
        sliceRender.graphics.endFill();

        sliceRender.x = xs[col];
        sliceRender.y = ys[row];
        render.addChild(sliceRender);
      }
    }

    bitmapData = new BitmapData(renderWidth, renderHeight, true, 0x00000000);
    bitmapData.draw(render);
  }

  /**
    Resize the frame

    @param newWidth   New width of the frame
    @param newHeight  New height of the frame
  **/
  public function resize(newWidth:Int, newHeight:Int) {
    render9Slice(newWidth, newHeight);
  }
}
