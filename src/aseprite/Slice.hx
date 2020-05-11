package aseprite;

import ase.chunks.SliceChunk;
import aseprite.NineSlice.NineSliceSlices;
import openfl.display.BitmapData;

/**
  Holds information regarding a slice
**/
class Slice {
  var _bitmapCache:Map<Int, BitmapData> = [];

  /**
    Cached bitmaps for frame indexes
  **/
  public var bitmapCache(get, never):Map<Int, BitmapData>;

  function get_bitmapCache():Map<Int, BitmapData>
    return _bitmapCache;

  var _chunk:SliceChunk;

  /**
    Parsed chunk data
  **/
  public var chunk(get, never):SliceChunk;

  function get_chunk():SliceChunk
    return _chunk;

  /**
    First 9Slice Slice Key
  **/
  public var firstKey(get, never):SliceKey;

  function get_firstKey():SliceKey
    return chunk.sliceKeys[0];

  /**
    Has 9 Slices
  **/
  public var has9Slices(get, never):Bool;

  function get_has9Slices():Bool
    return chunk.has9Slices;

  /**
    Slice name
  **/
  public var name(get, never):String;

  function get_name():String
    return _chunk.name;

  var _nineSliceCache:Map<Int, NineSliceSlices> = [];

  /**
    Cache of the 9Slices
  **/
  public var nineSliceCache(get, never):Map<Int, NineSliceSlices>;

  function get_nineSliceCache():Map<Int, NineSliceSlices>
    return _nineSliceCache;

  public function new(chunk:SliceChunk) {
    _chunk = chunk;
  }
}
