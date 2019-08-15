package aseprite;

import ase.chunks.PaletteChunk;

class Palette {
  private var _chunk:PaletteChunk;

  public var size(get, never):Int;

  function get_size():Int {
    return _chunk.paletteSize;
  }

  public function new(paletteChunk:PaletteChunk) {
    _chunk = paletteChunk;
  }
}
