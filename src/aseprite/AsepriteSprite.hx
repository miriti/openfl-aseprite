package aseprite;

import ase.Aseprite;
import ase.chunks.ChunkType;
import ase.chunks.LayerChunk;
import haxe.io.Bytes;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

class AsepriteSprite extends Sprite {
  private var _aseprite:Aseprite;
  private var _duration:Int = 0;
  private var _layers:Array<LayerChunk> = [];
  private var _frames:Array<AsepriteFrame> = [];
  private var _palette:Palette;
  private var _lastTime:Int;

  public var palette(get, never):Palette;

  function get_palette():Palette {
    return _palette;
  }

  public var aseprite(get, never):Aseprite;

  function get_aseprite():Aseprite {
    return _aseprite;
  }

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

  public var duration(get, never):Int;

  function get_duration():Int {
    return _duration;
  }

  public var frames(get, never):Array<AsepriteFrame>;

  function get_frames():Array<AsepriteFrame> {
    return _frames;
  }

  /*
    List of layer chunks
   */
  public var layers(get, never):Array<LayerChunk>;

  function get_layers():Array<LayerChunk> {
    return _layers;
  }

  /*
    Whether the animations should be looped or not
   */
  public var loop:Bool = true;

  /*
    Set current time of the sprite
   */
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
      var frame:AsepriteFrame = _frames[index];
      if (value >= frame.startTime && value < frame.startTime + frame.duration) {
        currentFrame = index;
        break;
      }
    }

    return time = value;
  }

  /*
    If set to true will use ENTER_FRAME event to update the state of the sprite.
    Otherwise update `time` of the sprite manually
    @default true
   */
  public var useEnterFrame(default, set):Bool = false;

  function set_useEnterFrame(value:Bool):Bool {
    if (!useEnterFrame && value) {
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    if (useEnterFrame && !value) {
      removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    return useEnterFrame = value;
  }

  /*
    Constructor
   */
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
      }
    }

    for (frame in _aseprite.frames) {
      var newFrame:AsepriteFrame = new AsepriteFrame(this, frame);
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

  public function play():AsepriteSprite {
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
