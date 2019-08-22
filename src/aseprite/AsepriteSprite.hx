package aseprite;

import ase.chunks.FrameTagsChunk;
import ase.Aseprite;
import ase.chunks.ChunkType;
import ase.chunks.LayerChunk;
import haxe.io.Bytes;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

/**
  The main class in the library
**/
class AsepriteSprite extends Sprite {
  private var _aseprite:Aseprite;
  private var _duration:Int = 0;
  private var _layers:Array<LayerChunk> = [];
  private var _frames:Array<Frame> = [];
  private var _palette:Palette;
  private var _lastTime:Int;
  private var _playing:Bool = false;
  private var _frameTags:FrameTagsChunk;
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
  public var aseprite(get, never):Aseprite;

  function get_aseprite():Aseprite {
    return _aseprite;
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
    Hasmap of animation tags by names
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
    Set current time of the sprite
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
  public var useEnterFrame(default, set):Bool = false;

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
    Constructor

    @param data       Bytes of the Aseprite file content
    @param masked     Whether or not the sprite should be masked to hide the
                      ontent outside of the sprites bounds
    @param background Background color of the sprite (null for transparent)
  **/
  public function new(data:Bytes, masked:Bool = true,
      background:Null<Int> = null) {
    super();

    _aseprite = new Aseprite(data);

    if (background != null) {
      graphics.beginFill(background);
      graphics.drawRect(0, 0, _aseprite.header.width, _aseprite.header.height);
      graphics.endFill();
    }

    for (chunk in _aseprite.frames[0].chunks) {
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

    for (frame in _aseprite.frames) {
      var newFrame:Frame = new Frame(this, frame);
      newFrame.visible = false;
      newFrame.startTime = _duration;
      _duration += newFrame.duration;
      _frames.push(newFrame);
      addChild(newFrame);
    }

    _frames[0].visible = true;

    if (masked) {
      var _mask:Sprite = new Sprite();
      _mask.graphics.beginFill(0x0);
      _mask.graphics.drawRect(0, 0, _aseprite.header.width, _aseprite.header.height);
      _mask.graphics.endFill();
      mask = _mask;
      addChild(_mask);
    }

    currentFrame = 0;
    useEnterFrame = true;

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
  **/
  public function play(?tagName:String):AsepriteSprite {
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
