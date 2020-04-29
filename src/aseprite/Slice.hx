package aseprite;

import ase.chunks.SliceChunk;

/**
  Holds information regarding a slice
**/
class Slice {
  var _chunk:SliceChunk;

  public var chunk(get, never):SliceChunk;

  function get_chunk():SliceChunk
    return _chunk;

  public function new(chunk:SliceChunk) {
    _chunk = chunk;
  }
}
