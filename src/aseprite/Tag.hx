package aseprite;

import ase.chunks.TagsChunk.Tag;

/**
  Holds information regarding a frame tag
**/
class Tag {
  private var _data:ase.chunks.TagsChunk.Tag;

  public var data(get, never):ase.chunks.TagsChunk.Tag;

  function get_data():ase.chunks.TagsChunk.Tag {
    return _data;
  }

  /**
    Name of the tag
  **/
  public var name(get, never):String;

  function get_name():String {
    return _data.tagName;
  }

  public function new(data:ase.chunks.TagsChunk.Tag) {
    _data = data;
  }
}
