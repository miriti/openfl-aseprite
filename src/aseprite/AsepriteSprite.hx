package aseprite;

import openfl.display.Sprite;
import ase.chunks.LayerChunk;
import ase.chunks.ChunkType;
import ase.Aseprite;
import haxe.io.Bytes;

class AsepriteSprite extends Sprite {
  private var _asepriteFile:Aseprite;
  private var _layers:Array<LayerChunk> = [];
  private var _frames:Array<AsepriteFrame> = [];
  private var _palette:Palette;

  public var palette(get, never):Palette;

  function get_palette():Palette {
    return _palette;
  }

  public var asepriteFile(get, never):Aseprite;

  function get_asepriteFile():Aseprite {
    return _asepriteFile;
  }

  public var layers(get, never):Array<LayerChunk>;

  function get_layers():Array<LayerChunk> {
    return _layers;
  }

  public function new(data:Bytes) {
    super();

    _asepriteFile = new Aseprite(data);

    for (chunk in _asepriteFile.frames[0].chunks) {
      switch (chunk.header.type) {
        case ChunkType.LAYER:
          _layers.push(cast chunk);
        case ChunkType.PALETTE:
          _palette = new Palette(cast chunk);
      }
    }

    for (frame in _asepriteFile.frames) {
      var newFrame:AsepriteFrame = new AsepriteFrame(this, frame);
      _frames.push(newFrame);
      addChild(newFrame);
    }
  }
}
