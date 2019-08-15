package aseprite;

import ase.chunks.CelChunk;
import ase.chunks.ChunkType;
import flash.display.Sprite;
import ase.Frame;

class AsepriteFrame extends Sprite {
  private var _frame:Frame;
  private var _layers:Array<AsepriteLayer> = [];

  public function new(sprite:AsepriteSprite, frame:Frame) {
    super();

    _frame = frame;

    for (layer in sprite.layers) {
      var newLayer:AsepriteLayer = new AsepriteLayer(layer);
      _layers.push(newLayer);
      addChild(newLayer);
    }

    for (chunk in frame.chunks) {
      if (chunk.header.type == ChunkType.CEL) {
        var cel:CelChunk = cast chunk;
        _layers[cel.layerIndex].addChild(new Cel(sprite, cast chunk));
      }
    }
  }
}
