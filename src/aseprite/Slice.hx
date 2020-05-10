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

  public var firstKey(get, never):SliceKey;

  function get_firstKey():SliceKey
    return chunk.sliceKeys[0];

  public var has9Slices(get, never):Bool;

  function get_has9Slices():Bool
    return chunk.has9Slices;

  public var name(get, never):String;

  function get_name():String
    return _chunk.name;

  public function new(chunk:SliceChunk) {
    _chunk = chunk;
  }
}
