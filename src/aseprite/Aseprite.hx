package aseprite;

import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;

typedef AsepriteFrameData = {
  frame: {
    x: Int,
    y: Int,
    w: Int,
    h: Int
  },
  rotated: Bool,
  trimmed: Bool,
  spriteSourceSize: {
    x: Int,
    y: Int,
    w: Int,
    h: Int
  },
  sourceSize: {
    w: Int,
    h: Int
  },
  duration: Int
};

typedef AsepriteFrame = {
  label: String,
  data: AsepriteFrameData,
  bitmapData: BitmapData
};

typedef AsepriteFrameTag = {
  name: String,
  from: Int,
  to: Int,
  direction: String
};

/**
  Aseprite class loads and parses json files created by Aseprite (https://www.aseprite.org/)
**/
class Aseprite extends Sprite {
  public static var enterFrameEvent: Bool = true;

  private var bitmap: Bitmap;
  private var currentFrameData(get, never): AsepriteFrame;
  private var currentFrameIndex(default, set): Int = -1;
  private var currentTag: AsepriteFrameTag = null;
  private var direction: Int = 1;
  private var frameCallbacks: Map<Int, Array<Void -> Void>> = new Map<Int, Array<Void -> Void>>();
  private var frames: Array<AsepriteFrame> = [];
  private var frameTags: Map<String, AsepriteFrameTag> = new Map<String, AsepriteFrameTag>();
  private var frameTime: Int = 0;
  private var lastTime: Null<Int> = null;
  private var repeat: Int = 0;
  private var stopCallback: Void -> Void = null;

  public var playing: Bool = false;
  public var reverse: Bool = false;
  public var speed: Float = 1;

  private function get_currentFrameData(): AsepriteFrame {
    return frames[currentFrameIndex];
  }

  private function set_currentFrameIndex(value: Int): Int {
    if(value < 0) value = frames.length - 1;
    if(value > frames.length - 1) value = 0;

    if(value != currentFrameIndex) {
      bitmap.bitmapData = frames[value].bitmapData;

      if(frameCallbacks.exists(value)) {
        for(callback in frameCallbacks.get(value)) {
          callback();
        }
      }
    }
    return currentFrameIndex = value;
  }

  public function new(jsonAssetName: String, bitmapAssetName: String = null) {
    super();

    if(bitmapAssetName == null) {
      bitmapAssetName = jsonAssetName.split('.').slice(0, -1).join('.') + '.png';
    }

    if(!Assets.exists(jsonAssetName)) {
      throw "Asset doesn't exists: " + jsonAssetName;
    }

    if(!Assets.exists(bitmapAssetName)) {
      throw "Asset doesn't exists: " + bitmapAssetName;
    }

    bitmap = new Bitmap();
    addChild(bitmap);

    loadJson(
        Assets.getText(jsonAssetName), 
        Assets.getBitmapData(bitmapAssetName)
        );

    if(enterFrameEvent) {
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
  }

  private function loadJson(json: String, bitmapData: BitmapData) {
    var jsonData = Json.parse(json);

    for(frame_label in Reflect.fields(jsonData.frames)) {
      var frameData:AsepriteFrameData = Reflect.field(jsonData.frames, frame_label);
      var newFrame: BitmapData = new BitmapData(frameData.sourceSize.w, frameData.sourceSize.h);

      newFrame.copyPixels(
          bitmapData, 
          new Rectangle(
            frameData.frame.x, 
            frameData.frame.y, 
            frameData.frame.w, 
            frameData.frame.h
            ),
          new Point(0, 0)
          );

      frames.push({
        label: frame_label,
        data: frameData,
        bitmapData: newFrame
      });
    }

    var labelToInt = function(lbl: String):Int {
      var num:Null<Int> = Std.parseInt(lbl.split("").filter(function(char) {
        return !(Std.parseInt(char) == null);
      }).join(""));

      return num == null ? 0 : num;
    };

    frames.sort(function(fa, fb) {
      var a:Int = labelToInt(fa.label);
      var b:Int = labelToInt(fb.label);
      return a > b ? 1 : (a == b) ? 0 : -1;
    });

    var tags:Array<AsepriteFrameTag> = jsonData.meta.frameTags;

    for(tag in tags) {
      frameTags.set(tag.name, tag);
    }

    if(tags.length > 0) {
      play(tags[0].name);
    } else {
      play();
    }
  }

  private function onEnterFrame(e: Event) {
    var currentTime: Int = Lib.getTimer();

    if(lastTime != null) {
      var delta:Int = currentTime - lastTime;
      update(delta);
    }

    lastTime = currentTime;
  }

  /**
   * Add a frame callback
   */
  public function addFrameCallback(frameNum: Int, callback: Void -> Void) {
    if(!frameCallbacks.exists(frameNum)) {
      frameCallbacks.set(frameNum, new Array<Void -> Void>());
    }
    frameCallbacks.get(frameNum).push(callback);
  }

  /**
   * Remove a frame callback
   */
  public function removeFrameCallback(frameNum: Int, callback: Void -> Void) {
    if(frameCallbacks.exists(frameNum)) {
      frameCallbacks.get(frameNum).remove(callback);
    }
  }

  public function play(tag: String = null) {
    if(tag != null) {
      if(frameTags.exists(tag)) {
        currentTag = frameTags.get(tag);
        currentFrameIndex = currentTag.from;
        frameTime = 0;
        repeat = 0;
        playing = true;
      } else {
        trace('Tag <' + tag + '> does not exists!');
      }
    } else {
      currentFrameIndex = 0;
      frameTime = 0;
      repeat = 0;
      playing = true;
    }
  }

  /**
      Play animation number of times
     
      @param times Number of times to play the animation
      @param tag  Tag to play
      @param callback If set will be called as soon as the last play time will be finished
   */
  public function playTimes(times: Int, tag: String = null, callback: Void -> Void = null) {
    play(tag);
    repeat = times;
    stopCallback = callback;
  }

  public function pause() {
    playing = false;
  }

  public function resume() {
    playing = true;
  }

  private function segmentEnd():Bool {
    if(repeat != 0) {
      repeat--;

      if(repeat == 0) {
        playing = false;
        if(stopCallback != null) {
          stopCallback();
        }
        dispatchEvent(new AsepriteEvent(AsepriteEvent.STOPPED));
        return false;
      }
    }

    return true;
  }

  // TODO: Fully rebuild this
  private function nextFrame() {
    var nextFrameIndex = currentFrameIndex + (direction * (reverse ? -1 : 1));

    if(currentTag != null) {
      // TODO pingpong
      if(nextFrameIndex > currentTag.to) {
        if(segmentEnd()) {
          nextFrameIndex = currentTag.from;
        } else {
          return;
        }
      }

      if(nextFrameIndex < currentTag.from) {
        if(segmentEnd()) {
          nextFrameIndex = currentTag.to;
        } else {
          return;
        }

      }
    } else {
      if(nextFrameIndex > frames.length - 1) {
        if(segmentEnd()) {
          nextFrameIndex = 0;
        } else {
          return;
        }

      }

      if(nextFrameIndex < 0) {
        if(segmentEnd()) {
          nextFrameIndex = frames.length - 1;
        } else {
          return;
        }

      }
    }

    currentFrameIndex = nextFrameIndex;
  }

  public function update(delta: Int) {
    if(playing) {
      frameTime += delta;

      if(frameTime >= currentFrameData.data.duration) {
        frameTime = currentFrameData.data.duration - frameTime;
        nextFrame();
      }
    }
  }
}
