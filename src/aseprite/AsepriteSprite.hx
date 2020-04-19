package aseprite;

import ase.AnimationDirection;
import ase.Aseprite;
import ase.chunks.ChunkType;
import ase.chunks.LayerChunk;
import ase.chunks.TagsChunk;
import haxe.io.Bytes;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

/**
  The main class in the library
**/
class AsepriteSprite extends Sprite {
  private var _alternatingDirection:Int = AnimationDirection.FORWARD;
  private var _direction:Int = AnimationDirection.FORWARD;
  private var _frameTags:TagsChunk;
  private var _frameTime:Int = 0;
  private var _frames:Array<Frame> = [];
  private var _lastTime:Int;
  private var _layers:Array<LayerChunk> = [];
  private var _palette:Palette;
  private var _playing:Bool = true;
  private var _spriteLayers = {
    background: new Sprite(),
    image: new Sprite()
  };

  private var _tags:Map<String, aseprite.Tag> = [];

  /**
    Direction of the animation:

    1 - Forward
    2 - Reverse
    3 - Ping-Pong
  **/
  public var direction(get, set):Int;

  function get_direction():Int {
    return
      currentTag != null ? tags[currentTag].data.animDirection : _direction;
  }

  function set_direction(value:Int):Int {
    if (currentTag != null) {
      tags[currentTag].data.animDirection = value;
    }

    return _direction = value;
  }

  /**
    Starting frame of the animation or the current tag
  **/
  public var fromFrame(get, never):Int;

  function get_fromFrame():Int {
    return currentTag != null ? tags[currentTag].data.fromFrame : 0;
  }

  /**
    Ending frame of the animation or the current tag
  **/
  public var toFrame(get, never):Int;

  function get_toFrame():Int {
    return currentTag != null ? tags[currentTag].data.toFrame : _frames.length
      - 1;
  }

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
          case ChunkType.TAGS:
            _frameTags = cast chunk;

            for (frameTagData in _frameTags.tags) {
              var animationTag:aseprite.Tag = new aseprite.Tag(frameTagData);

              if (_tags.exists(frameTagData.tagName)) {
                var num:Int = 1;
                var newName:String = '${frameTagData.tagName}_$num';
                while (_tags.exists(newName)) {
                  num++;
                  newName = '${frameTagData.tagName}_$num';
                }
                trace('WARNING: This file already contains tag named "${frameTagData.tagName}". It will be automatically reanamed to "$newName"');
                _tags[newName] = animationTag;
              } else {
                _tags[frameTagData.tagName] = animationTag;
              }
            }
        }
      }

      _frames = [];

      for (frame in aseprite.frames) {
        var newFrame:Frame = new Frame(this, frame);
        newFrame.visible = false;
        newFrame.startTime = _totalDuration;
        _totalDuration += newFrame.duration;
        _frames.push(newFrame);
        _spriteLayers.image.addChild(newFrame);
      }

      _frames[0].visible = true;
      currentFrame = 0;
    }

    return aseprite;
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
    }

    return currentFrame;
  }

  /**
    Current playing tag. Set to `null` in order to reset

    @default null
  **/
  public var currentTag(default, set):String = null;

  function set_currentTag(value:String):String {
    if (value != currentTag && tags.exists(value)) {
      currentTag = value;
      _alternatingDirection = AnimationDirection.FORWARD;
      if (currentFrame < tags[currentTag].data.fromFrame
        || currentFrame > tags[currentTag].data.toFrame)
        currentFrame = tags[currentTag].data.fromFrame;
    }
    return currentTag;
  }

  private var _totalDuration:Int = 0;

  /**
    The total duration of the sprite
  **/
  public var totalDuration(get, never):Int;

  function get_totalDuration():Int {
    return _totalDuration;
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
    Map of animation tags by names
  **/
  public var tags(get, never):Map<String, aseprite.Tag>;

  function get_tags():Map<String, aseprite.Tag> {
    return _tags;
  }

  /**
    If set to true will use ENTER_FRAME event to update the state of the sprite.
    Otherwise update `time` of the sprite manually
  **/
  public var useEnterFrame(default, set):Bool;

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
    Create a Sprite from a Bytes

    @param byteArray       ByteArray with file data
    @param useEnterFrame   If `true` add an `ENTER_FRAME` event listener to advence the animation
  **/
  public static function fromBytes(bytes:Bytes,
      useEnterFrame:Bool = true):AsepriteSprite {
    return new AsepriteSprite(Aseprite.fromBytes(bytes), useEnterFrame);
  }

  /**
    Constructor

    @param aseprite       An Aseprite instance of a parser ase/aseprite file
    @param useEnterFrame  If `true` add an `ENTER_FRAME` event listener to advence the animation
  **/
  private function new(aseprite:Aseprite, useEnterFrame:Bool = true) {
    super();
    this.aseprite = aseprite;
    this.useEnterFrame = useEnterFrame;
    addChild(_spriteLayers.background);
    addChild(_spriteLayers.image);
    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }

  /**
    Advance animation by `time` milliseconds

    @param time Time in milliseconds
  **/
  public function advance(time:Int):AsepriteSprite {
    if (time < 0) // TODO
      throw 'TODO: time value can be negative';

    _frameTime += time;

    while (_frameTime > _frames[currentFrame].duration) {
      _frameTime -= _frames[currentFrame].duration;
      nextFrame();
    }

    return this;
  }

  /**
    Go to the next frame respecting the direction of the current animation
  **/
  public function nextFrame():AsepriteSprite {
    var currentDirection:Int = direction;
    if (direction == AnimationDirection.PING_PONG) {
      currentDirection = _alternatingDirection;
    }

    switch (currentDirection) {
      case(AnimationDirection.FORWARD):
        if (currentFrame + 1 > toFrame) {
          if (direction == AnimationDirection.PING_PONG) {
            currentFrame--;
            _alternatingDirection = AnimationDirection.REVERSE;
          } else
            currentFrame = fromFrame;
        } else {
          currentFrame++;
        }
      case(AnimationDirection.REVERSE):
        if (currentFrame - 1 < fromFrame) {
          if (direction == AnimationDirection.PING_PONG) {
            currentFrame++;
            _alternatingDirection = AnimationDirection.FORWARD;
          } else
            currentFrame = toFrame;
        } else {
          currentFrame--;
        }
    }

    return this;
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
  public function play(?tagName:String = null):AsepriteSprite {
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
    currentFrame = fromFrame;
    return this;
  }

  function onAddedToStage(e:Event) {
    _lastTime = Lib.getTimer();
  }

  function onEnterFrame(e:Event) {
    var _currentTime:Int = Lib.getTimer();
    var _deltaTime:Int = _currentTime - _lastTime;
    if (_playing) {
      advance(_deltaTime);
    }
    _lastTime = _currentTime;
  }
}
