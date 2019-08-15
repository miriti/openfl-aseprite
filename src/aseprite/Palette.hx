package aseprite;

import haxe.io.Bytes;
import haxe.Int32;
import ase.chunks.PaletteChunk;

class Palette {
  private var _chunk:PaletteChunk;
  private var _entries:Map<Int, Int32> = [];

  public var entries(get, never):Map<Int, Int32>;

  function get_entries():Map<Int, Int32> {
    return _entries;
  }

  public var size(get, never):Int;

  function get_size():Int {
    return _chunk.paletteSize;
  }

  public function new(paletteChunk:PaletteChunk) {
    _chunk = paletteChunk;

    for (index in _chunk.entries.keys()) {
      var entry = _chunk.entries[index];
      var color:Bytes = Bytes.alloc(4);
      color.set(0, entry.blue);
      color.set(1, entry.green);
      color.set(2, entry.red);
      color.set(3, entry.alpha);
      _entries[index] = color.getInt32(0);
    }
  }
}
