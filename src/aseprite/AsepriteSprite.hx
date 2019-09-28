package aseprite;

import ase.Aseprite;
import ase.chunks.ChunkType;
import ase.chunks.FrameTagsChunk;
import ase.chunks.LayerChunk;
import haxe.io.Bytes;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.utils.ByteArray;

/**
  The main class in the library
**/
class AsepriteSprite extends Sprite {
  private var _duration:Int = 0;
  private var _frames:Array<Frame> = [];
  private var _frameTags:FrameTagsChunk;
  private var _lastTime:Int;
  private var _layers:Array<LayerChunk> = [];
  private var _palette:Palette;
  private var _playing:Bool = false;

  private var _spriteLayers = {
    background: new Sprite(),
    image: new Sprite()
  };
  private var _tag:Map<String, Tag> = [];
  private var _tags:Array<Tag> = [];

  /**
    Palette
  **/
  public var palette(get, never):Palette;

  function get_palette():Palette {
    return _palette;
  }

  /**
    Parsed Aseprite file data
  **/
  public var aseprite(default, set):Aseprite;

  function set_aseprite(value:Aseprite):Aseprite {
    if (value != aseprite) {
      aseprite = value;
      for (chunk in aseprite.frames[0].chunks) {
        switch (chunk.header.type) {
          case ChunkType.LAYER:
            _layers.push(cast chunk);
          case ChunkType.PALETTE:
            _palette = new Palette(cast chunk);
          case ChunkType.FRAME_TAGS:
            _frameTags = cast chunk;

            for (frameTagData in _frameTags.tags) {
              var animationTag:Tag = new Tag(frameTagData);

              _tags.push(animationTag);

              if (_tag.exists(frameTagData.tagName)) {
                var num:Int = 1;
                var newName:String = '${frameTagData.tagName}_$num';
                while (_tag.exists(newName)) {
                  num++;
                  newName = '${frameTagData.tagName}_$num';
                }
                trace('WARNING: This file already contains tag named "${frameTagData.tagName}". It will be automatically reanamed to "$newName"');
                _tag[newName] = animationTag;
              } else {
                _tag[frameTagData.tagName] = animationTag;
              }
            }
        }
      }

      _frames = [];

      for (frame in aseprite.frames) {
        var newFrame:Frame = new Frame(this, frame);
        newFrame.visible = false;
        newFrame.startTime = _duration;
        _duration += newFrame.duration;
        _frames.push(newFrame);
        _spriteLayers.image.addChild(newFrame);
      }

      _frames[0].visible = true;
      currentFrame = 0;
      masked = masked;
    }

    return aseprite;
  }

  /**
    Background color of the sprite. `null` for transparend

    @default null
  **/
  public var backgroundColor(default, set):Null<Int> = null;

  function set_backgroundColor(value:Null<Int>):Null<Int> {
    if (aseprite != null) {
      if (value != null) {
        _spriteLayers.background.graphics.beginFill(backgroundColor);
        _spriteLayers.background.graphics.drawRect(0, 0, aseprite.header.width, aseprite.header.height);
        _spriteLayers.background.graphics.endFill();
      } else {
        _spriteLayers.background.graphics.clear();
      }
    }
    return backgroundColor = value;
  }

  /**
    Current frame index of the animation (0...frames.length)
  **/
  public var currentFrame(default, set):Int = 0;

  function set_currentFrame(value:Int):Int {
    if (value < 0)
      value = 0;
    if (value >= _frames.length)
      value = _frames.length - 1;

    if (value != currentFrame) {
      _frames[currentFrame].visible = false;
      currentFrame = value;
      _frames[currentFrame].visible = true;
      dispatchEvent(new AsepriteEvent(AsepriteEvent.FRAME_CHANGE));
    }

    return currentFrame;
  }

  /**
    Current playing tag. Set to `null` in order to reset

    @default null
  **/
  public var currentTag(default, set):String = null;

  function set_currentTag(value:String):String {
    if (value != currentTag && _tag.exists(value)) {
      currentTag = value;
    }
    return currentTag;
  }

  /**
    The duration of the whole animation or the current frame
  **/
  public var duration(get, never):Int;

  function get_duration():Int {
    return _duration;
  }

  /**
    Array of animation frames
  **/
  public var frames(get, never):Array<Frame>;

  function get_frames():Array<Frame> {
    return _frames;
  }

  /**
    List of layer chunks
  **/
  public var layers(get, never):Array<LayerChunk>;

  function get_layers():Array<LayerChunk> {
    return _layers;
  }

  /**
    Whether the animations should be looped or not
  **/
  public var loop:Bool = true;

  /**
    Whether the the Sprite should be masked or not
  **/
  public var masked(default, set):Bool;

  function set_masked(value:Bool) {
    if (masked && !value) {
      _spriteLayers.image.removeChild(mask);
      _spriteLayers.image.mask = null;
    }

    if (!masked && value) {
      if (aseprite != null) {
        var _mask:Sprite = new Sprite();
        _mask.graphics.beginFill(0x0);
        _mask.graphics.drawRect(0, 0, aseprite.header.width, aseprite.header.height);
        _mask.graphics.endFill();
        _spriteLayers.image.mask = _mask;
        _spriteLayers.image.addChild(_mask);
      }
    }
    return masked = value;
  }

  /**
    Map of animation tags by names
  **/
  public var tag(get, never):Map<String, Tag>;

  function get_tag():Map<String, Tag> {
    return _tag;
  }

  /**
    Array of animation tags
  **/
  public var tags(get, never):Array<Tag>;

  function get_tags():Array<Tag> {
    return _tags;
  }

  /**
    Set current time of the sprite in milliseconds
  **/
  public var time(default, set):Int = 0;

  function set_time(value:Int):Int {
    if (value > duration) {
      if (loop) {
        while (value > duration) {
          value -= duration;
        }
      } else {
        value = duration;
      }
    }

    for (index in 0..._frames.length) {
      var frame:Frame = _frames[index];
      if (value >= frame.startTime && value < frame.startTime + frame.duration) {
        currentFrame = index;
        break;
      }
    }

    return time = value;
  }

  /**
    If set to true will use ENTER_FRAME event to update the state of the sprite.
    Otherwise update `time` of the sprite manually

    @default true
  **/
  public var useEnterFrame(default, set):Bool = true;

  function set_useEnterFrame(value:Bool):Bool {
    if (!useEnterFrame && value) {
      _lastTime = Lib.getTimer();
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    if (useEnterFrame && !value) {
      removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    return useEnterFrame = value;
  }

  /**
    Constructs an `AsepriteSprite` from an `Aseprite` instance, `masked` and
    `backgroundColor` parameters

    @param aseprite        `Aseprite` instance
    @param masked          Whether or not the sprite should be masked to hide the
                           content outside of the sprites bounds
    @param backgroundColor Background color of the sprite (null for transparent)
  **/
  public static function construct(aseprite:Aseprite, ?masked:Bool,
      ?backgroundColor:Int):AsepriteSprite {
    var asepriteSprite:AsepriteSprite = new AsepriteSprite();
    asepriteSprite.aseprite = aseprite;
    asepriteSprite.backgroundColor = backgroundColor;
    asepriteSprite.masked = masked;
    return asepriteSprite;
  }

  /**
    Create a Sprite from a Bytes

    @param byteArray       ByteArray with file data
    @param masked          Whether or not the sprite should be masked to hide the
                           content outside of the sprites bounds
    @param backgroundColor Background color of the sprite (null for transparent)
  **/
  public static function fromBytes(bytes:Bytes, ?masked:Bool,
      ?backgroundColor:Int):AsepriteSprite {
    return construct(Aseprite.fromBytes(bytes), masked, backgroundColor);
  }

  /**
    Create a Sprite from a ByteArray

    @param byteArray       ByteArray with file data
    @param masked          Whether or not the sprite should be masked to hide the
                           content outside of the sprites bounds
    @param backgroundColor Background color of the sprite (null for transparent)
  **/
  public static function fromByteArray(byteArray:ByteArray,
      ?masked:Bool = false, ?backgroundColor:Int):AsepriteSprite {
    return construct(Aseprite.fromBytesInput(null), masked, backgroundColor);
  }

  /**
    Constructor
  **/
  private function new() {
    super();
    addChild(_spriteLayers.background);
    addChild(_spriteLayers.image);
    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }

  /**
    Pause the playback
  **/
  public function pause():AsepriteSprite {
    _playing = false;
    return this;
  }

  /**
    Start playing the animation

    @param tagName Name of the tag to play
  **/
  public function play(?tagName:String):AsepriteSprite {
    if (tagName != null)
      currentTag = tagName;
    _playing = true;
    return this;
  }

  /**
    Pause the animation and bring the playhead to the beginning
  **/
  public function stop():AsepriteSprite {
    pause();
    currentFrame = 0;
    return this;
  }

  function onAddedToStage(e:Event) {
    _lastTime = Lib.getTimer();
  }

  function onEnterFrame(e:Event) {
    var _currentTime:Int = Lib.getTimer();
    var _deltaTime:Int = _currentTime - _lastTime;
    time += _deltaTime;
    _lastTime = _currentTime;
  }
}
