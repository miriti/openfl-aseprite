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

  public var name(get, never):String;

  function get_name():String
    return _chunk.name;

  public function new(chunk:SliceChunk) {
    _chunk = chunk;
  }
}
