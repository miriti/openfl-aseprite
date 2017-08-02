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

class Aseprite extends Sprite {
  public static var enterFrameEvent: Bool = true;

  private var bitmap: Bitmap;
  private var currentFrameData(get, never): AsepriteFrame;
  private var currentFrameIndex(default, set): Int;
  private var direction: Int = 1;
  private var frames: Array<AsepriteFrame> = [];
  private var frameTags: Map<String, AsepriteFrameTag> = new Map<String, AsepriteFrameTag>();
  private var frameTime: Int = 0;
  private var currentTag: AsepriteFrameTag = null;
  private var lastTime: Null<Int> = null;

  public var reverse: Bool = false;
  public var speed: Float = 1;

  private function get_currentFrameData(): AsepriteFrame {
    return frames[currentFrameIndex];
  }

  private function set_currentFrameIndex(value: Int): Int {
    if(value < 0) value = frames.length - 1;
    if(value > frames.length - 1) value = 0;

    bitmap.bitmapData = frames[value].bitmapData;
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

  public function play(tag: String = null) {
    if(tag != null) {
      if(frameTags.exists(tag)) {
        currentTag = frameTags.get(tag);
        currentFrameIndex = currentTag.from;
        frameTime = 0;
      }
    } else {
      currentFrameIndex = 0;
      frameTime = 0;
    }
  }

  private function nextFrame() {
    var nextFrameIndex = currentFrameIndex + (direction * (reverse ? -1 : 1));

    if(currentTag != null) {
      // TODO pingpong
      if(nextFrameIndex > currentTag.to) {
        nextFrameIndex = currentTag.from;
      }

      if(nextFrameIndex < currentTag.from) {
        nextFrameIndex = currentTag.to;
      }
    } else {
      if(nextFrameIndex > frames.length - 1) {
        nextFrameIndex = 0;
      }

      if(nextFrameIndex < 0) {
        nextFrameIndex = frames.length - 1;
      }
    }

    currentFrameIndex = nextFrameIndex;
  }

  public function update(delta: Int) {
    frameTime += delta;

    if(frameTime >= currentFrameData.data.duration) {
      frameTime = currentFrameData.data.duration - frameTime;
      nextFrame();
    }
  }
}
