package aseprite;

import ase.AnimationDirection;
import ase.Ase;
import ase.chunks.ChunkType;
import ase.chunks.LayerChunk;
import ase.chunks.TagsChunk;
import haxe.io.Bytes;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;

/**
  The main class in the library

  ```haxe
  var sprite:Aseprite = Aseprite.fromBytes(Assets.getBytes('path/to/asepriteAsset.aseprite'));
  addChild(sprite);
  ```
**/
class Aseprite extends Sprite {
  private var _alternatingDirection:Int = AnimationDirection.FORWARD;
  private var _ase:Ase;
  private var _bitmap:Bitmap;
  private var _currentRepeat:Int = 0;
  private var _direction:Int = AnimationDirection.FORWARD;
  private var _frameTags:TagsChunk;
  private var _frameTime:Int = 0;
  private var _frames:Array<Frame> = [];
  private var _lastTime:Int;
  private var _layers:Array<LayerChunk> = [];
  private var _onFinished:Void->Void = null;
  private var _onFrame:Array<Int->Void> = [];
  private var _onTag:Array<Array<String>->Void> = [];
  private var _palette:Palette;
  private var _playing:Bool = false;
  private var _repeats:Int = -1;
  private var _slice:Slice = null;
  private var _slices:Map<String, Slice> = [];

  private var _tags:Map<String, aseprite.Tag> = [];

  /**
    Direction of the animation:

    ```
    0 - Forward
    1 - Reverse
    2 - Ping-Pong
    ```
  **/
  public var direction(get, set):Int;

  function get_direction():Int
    return
      currentTag != null ? tags[currentTag].chunk.animDirection : _direction;

  function set_direction(value:Int):Int {
    if (currentTag != null) {
      tags[currentTag].chunk.animDirection = value;
    }

    return _direction = value;
  }

  /**
    Starting frame of the animation or the current tag
  **/
  public var fromFrame(get, never):Int;

  function get_fromFrame():Int
    return currentTag != null ? tags[currentTag].chunk.fromFrame : 0;

  /**
    Ending frame of the animation or the current tag
  **/
  public var toFrame(get, never):Int;

  function get_toFrame():Int
    return currentTag != null ? tags[currentTag].chunk.toFrame : _frames.length
      - 1;

  /**
    Sprite's palette

    ```haxe
    for(index => color in sprite.palette.entries) {
      trace('Paletter entry $index: #${StringTools.hex(color, 6)}');
    }
    ```
  **/
  public var palette(get, never):Palette;

  function get_palette():Palette
    return _palette;

  /**
    Parsed Aseprite file data
  **/
  public var ase(get, never):Ase;

  function get_ase():Ase
    return _ase;

  /**
    Current frame index of the animation (0...frames.length)
  **/
  public var currentFrame(default, set):Int = 0;

  function set_currentFrame(value:Int):Int {
    if (value < 0)
      value = 0;
    if (value >= _frames.length)
      value = _frames.length - 1;

    if (_bitmap.bitmapData == null) {
      _bitmap.bitmapData = _frames[value].bitmapData;
    }

    if (value != currentFrame) {
      var prevFrame = currentFrame;
      currentFrame = value;
      _bitmap.bitmapData = _frames[currentFrame].bitmapData;
      for (handler in _onFrame) {
        handler(currentFrame);
      }

      var tagsChanged:Bool = _frames[prevFrame].tags.length != _frames[currentFrame].tags.length;

      if (!tagsChanged) {
        // TODO: DRY
        for (tag in _frames[currentFrame].tags) {
          if (_frames[prevFrame].tags.indexOf(tag) == -1) {
            tagsChanged = true;
            break;
          }
        }
        for (tag in _frames[prevFrame].tags) {
          if (_frames[currentFrame].tags.indexOf(tag) == -1) {
            tagsChanged = true;
            break;
          }
        }
      }

      if (tagsChanged) {
        for (handler in _onTag) {
          handler(_frames[currentFrame].tags);
        }
      }
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
      if (currentFrame < tags[currentTag].chunk.fromFrame
        || currentFrame > tags[currentTag].chunk.toFrame)
        currentFrame = (tags[currentTag].chunk.animDirection == AnimationDirection.FORWARD
          || tags[currentTag].chunk.animDirection == AnimationDirection.PING_PONG) ? tags[currentTag].chunk.fromFrame : tags[currentTag].chunk.toFrame;
    }
    return currentTag;
  }

  public var isPlaying(get, never):Bool;

  function get_isPlaying():Bool
    return _playing;

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

  function get_frames():Array<Frame>
    return _frames;

  /**
    List of layer chunks
  **/
  public var layers(get, never):Array<LayerChunk>;

  function get_layers():Array<LayerChunk>
    return _layers;

  /**
    An array of function that will be called on every frame change

    ```haxe
    sprite.onFrame.push((frameIndex:Int) -> {
      trace('Frame index changed to: ${frameIndex}');
    });
    ```
  **/
  public var onFrame(get, never):Array<Int->Void>;

  function get_onFrame():Array<Int->Void>
    return _onFrame;

  /**
    An array of functions that will be called every time
    tags of the current frame are different from the tags of the previous frame

    ```haxe
    sprite.onTag.push((tags:Array<String>) -> {
      trace('Current tags are: ${tags.join(', ')}');
    });
    ```
  **/
  public var onTag(get, never):Array<Array<String>->Void>;

  function get_onTag():Array<Array<String>->Void>
    return _onTag;

  /**
    If the sprite was created from a Slice represents the data of this Slice
  **/
  public var slice(get, never):Slice;

  function get_slice():Slice {
    return _slice;
  }

  /**
    Array of `Slice`s
  **/
  public var slices(get, never):Map<String, Slice>;

  function get_slices():Map<String, Slice>
    return _slices;

  /**
    Map of animation tags by names
  **/
  public var tags(get, never):Map<String, aseprite.Tag>;

  function get_tags():Map<String, aseprite.Tag>
    return _tags;

  /**
    If set to `true` will use `ENTER_FRAME` event to update the state of the sprite.
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
    Create a Sprite from a `Bytes` instance

    @param byteArray       ByteArray with file data
    @param useEnterFrame   If `true` add an `ENTER_FRAME` event listener to advence the animation
  **/
  public static function fromBytes(bytes:Bytes,
      useEnterFrame:Bool = true):Aseprite {
    return new Aseprite(Ase.fromBytes(bytes), useEnterFrame);
  }

  /**
    Constructor

    @param ase            An Ase instance of a parser ase/aseprite file
    @param sprite         Base sprite
    @param useEnterFrame  If `true` add an `ENTER_FRAME` event listener to advence the animation
    @param spriteWidth    Width of the newly created sprite.
    @param spriteHeight   Height of the newly created sprite.
  **/
  private function new(?ase:Ase, ?sprite:Aseprite, ?slice:Slice,
      useEnterFrame:Bool = true, ?spriteWidth:Int, ?spriteHeight:Int) {
    super();

    _bitmap = new Bitmap();
    addChild(_bitmap);

    if (ase != null)
      parseAseprite(ase);

    if (sprite != null)
      copyFromSprite(sprite, slice, spriteWidth, spriteHeight);

    this.useEnterFrame = useEnterFrame;

    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }

  /**
    Advance animation by `time` milliseconds

    @param time Time in milliseconds
  **/
  public function advance(time:Int):Aseprite {
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
  public function nextFrame():Aseprite {
    var currentDirection:Int = direction;
    if (direction == AnimationDirection.PING_PONG) {
      currentDirection = _alternatingDirection;
    }

    var futureFrame:Int = currentFrame;
    var alternateDirection:Int = currentDirection;

    if (currentDirection == AnimationDirection.FORWARD) {
      futureFrame = currentFrame + 1;
      alternateDirection = AnimationDirection.REVERSE;
    } else if (currentDirection == AnimationDirection.REVERSE) {
      futureFrame = currentFrame - 1;
      alternateDirection = AnimationDirection.FORWARD;
    }

    if (futureFrame > toFrame || futureFrame < fromFrame) {
      if ((_repeats == -1) || (_repeats != -1 && --_currentRepeat > 0)) {
        if (direction == AnimationDirection.PING_PONG) {
          currentFrame += alternateDirection == AnimationDirection.FORWARD ? 1 : -1;
          _alternatingDirection = alternateDirection;
        } else {
          currentFrame = fromFrame;
        }
      } else {
        pause();
        if (_onFinished != null) {
          _onFinished();
          _onFinished = null;
        }
      }
    } else {
      currentFrame = futureFrame;
    }

    return this;
  }

  /**
    Pause the playback
  **/
  public function pause():Aseprite {
    _playing = false;
    return this;
  }

  /**
    Start playing the animation

    @param tagName    Name of the tag to play
    @param repeats    Number of repeats (-1 - infinite)
    @param onFinished Callback that will be called when repeats are finished (won't be called if `repeats == -1`)
  **/
  public function play(?tagName:String = null, ?repeats:Int = -1,
      ?onFinished:Void->Void = null):Aseprite {
    if (tagName != null)
      currentTag = tagName;
    _playing = true;
    _repeats = _currentRepeat = repeats;
    _onFinished = onFinished;
    return this;
  }

  /**
    Create a copy of this sprite bypassing file data parsing by reusing the resources

    @param sliceName      Name of the slice to cut from the sprite
    @param spriteWidth    Width of the newly created sprite.
    @param spriteHeight   Height of the newly created sprite.
    @param useEnterFrame  Use `ENTER_FRAME` event to advance the animation
  **/
  public function spawn(?sliceName:String, ?spriteWidth:Int,
      ?spriteHeight:Int, ?useEnterFrame:Null<Bool> = null):Aseprite {
    return new Aseprite(this, slices[sliceName],
      useEnterFrame == null ? this.useEnterFrame : useEnterFrame, spriteWidth,
      spriteHeight);
  }

  /**
    Pause the animation and bring the playhead to the first frame of the animation or the current tag
  **/
  public function stop():Aseprite {
    pause();
    currentFrame = fromFrame;
    _currentRepeat = _repeats;
    return this;
  }

  function copyFromSprite(sprite:Aseprite, ?slice:Slice, ?spriteWidth:Int,
      ?spriteHeight:Int) {
    _ase = sprite.ase;
    _layers = sprite._layers;
    _palette = sprite._palette;
    _frameTags = sprite._frameTags;
    _tags = sprite._tags;
    _slices = sprite._slices;

    _totalDuration = sprite._totalDuration;

    for (frame in sprite.frames) {
      var copyFrame = frame.copy(slice, spriteWidth, spriteHeight);
      _frames.push(copyFrame);
    }

    currentFrame = 0;
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

  function parseAseprite(value:Ase):Ase {
    if (value != _ase) {
      _ase = value;
      for (chunk in ase.frames[0].chunks) {
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
          case ChunkType.SLICE:
            var newSlice = new Slice(cast chunk);
            _slices[newSlice.name] = newSlice;
        }
      }

      for (index in 0...ase.frames.length) {
        var frame = ase.frames[index];
        var newFrame:Frame = new Frame(index, this, frame);
        _totalDuration += newFrame.duration;
        _frames.push(newFrame);
      }

      for (tag in tags) {
        for (frameIndex in tag.chunk.fromFrame...tag.chunk.toFrame + 1) {
          frames[frameIndex].tags.push(tag.name);
        }
      }

      currentFrame = 0;
    }

    return ase;
  }

  /**
    Resize all the frames
  **/
  public function resize(newWidth:Int, newHeight:Int) {
    for (frame in frames) {
      frame.resize(newWidth, newHeight);
    }

    _bitmap.bitmapData = frames[currentFrame].bitmapData;
  }
}
