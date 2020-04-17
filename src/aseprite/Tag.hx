package aseprite;

import ase.chunks.FrameTagsChunk.FrameTag;

/**
  Holds information regarding a frame tag
**/
class Tag {
  private var _data:FrameTag;

  public var data(get, never):FrameTag;

  function get_data():FrameTag {
    return _data;
  }

  /**
    Name of the tag
  **/
  public var name(get, never):String;

  function get_name():String {
    return _data.tagName;
  }

  public function new(data:FrameTag) {
    _data = data;
  }
}
