package aseprite;

/**
  Holds information regarding a frame tag
**/
class Tag {
  private var _chunk:ase.chunks.TagsChunk.Tag;

  /**
    Aseprite `Tag` chunk data
  **/
  public var chunk(get, never):ase.chunks.TagsChunk.Tag;

  function get_chunk():ase.chunks.TagsChunk.Tag {
    return _chunk;
  }

  /**
    Name of the tag
  **/
  public var name(get, never):String;

  function get_name():String {
    return _chunk.tagName;
  }

  public function new(data:ase.chunks.TagsChunk.Tag) {
    _chunk = data;
  }
}
