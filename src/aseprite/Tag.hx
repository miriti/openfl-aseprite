package aseprite;

import ase.chunks.FrameTagsChunk.FrameTag;

/**
  Holds information in regard to frame tag
**/
class Tag {
  private var _data:FrameTag;

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
