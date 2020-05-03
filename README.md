# OpenFL Aseprite

Load and render sprites and animations in Aseprite format. Based on [ase](https://github.com/miriti/ase) library.

[Demo 1](https://miriti.github.io/openfl-aseprite/examples/aseprite-viewer/Export/html5/bin/index.html) [Source](https://github.com/miriti/openfl-aseprite/tree/master/examples/aseprite-viewer)

[Demo 2](https://miriti.github.io/openfl-aseprite/examples/multiple-sprites/Export/html5/bin/index.html) [Source](https://github.com/miriti/openfl-aseprite/tree/master/examples/multiple-sprites)

[API Documentation](https://miriti.github.io/openfl-aseprite/documentation/index.html)

## Installation

1. Install the library with `haxelib`:

```
haxelib install openfl-aseprite
```

2. Add this to the `project.xml` file:

```xml
 <haxelib name="openfl-aseprite" />
```

## Usage

The main class of the library (`aseprite.AsepriteSprite`) extends `openfl.display.Sprite` so you can use it just like any other OpenFL sprite.

```haxe
import aseprite.AsepriteSprite;
import openfl.Assets;

// <...>

var sprite:AsepriteSprite = AsepriteSprite.fromBytes(Assets.getBytes('path/to/asepriteAsset.aseprite'));

addChild(sprite);
```

Create a new sprite reusing the resources:

```haxe
var sprite:AsepriteSprite = AsepriteSprite.fromBytes(Assets.getBytes('path/to/asepriteAsset.aseprite'));
var newSprite:AsepriteSprite = sprite.spawn();
```

`newSprite` will share the bitmap data from the original sprite thus saving memory and time used to parse the aseprite file data

`spawn` method can also be used to create new sprites from slices:

```haxe
var newSprite:AsepriteSprite = sprite.spawn('Slice Name');
```

By default an `AsepriteSprite` instance adds an `ENTER_FRAME` listener to advance the animation automatically. If you don't want it you can pass `false` as a second argument of the constructor or the `fromBytes` method. To advance the animation manually use `advance` or `nextFrame` methods or `currentFrame` property;

```haxe

var sprite:AsepriteSprite = AsepriteSprite.fromBytes(Assets.getBytes('path/to/asepriteAsset.aseprite'), false); // Won't add an `ENTER_FRAME` listener

sprite.advance(300); // Advance the animation by 300 milliseconds

sprite.nextFrame(); // Go to the next frame of the animation

sprite.currentFrame = 32; // Explicitly set the current frame of the animation

```

### Playback and tags

```haxe
sprite.play(); // If no tag specified - play from the first frame to the end of the animation

sprite.play(3); // Play the animation 3 times

/**
   Play animation once with `onFinish` callback
 */
sprite.play(1, () -> {
  trace('Animation is finished');
});

sprite.play('tag_name'); // Start playing a specific tag if it's not playing already

sprite.play('tag_name', 3); // Play `tag_name` tag 3 times

/**
  Play `tag_name` tag 3 times with an `onFinish` callback
 */
sprite.play('tag_name', 3, () -> {
  trace('Playback is finished after 3 repeats');
});

sprite.pause(); // Pauses the playback

sprite.stop(); // Stops the playback and moves the playhead to the first frame of the animation or the current tag;
```

**NOTE**: The methods above only make sense if `useEnterFrame = true`

```haxe
for(tag in sprite.tags) { // Loop through the animation tags
  trace(tag.name); // Print tag's name
}

sprite.currentTag = 'tag_name'; // Change the current tag. If other tag is currently playing - go to the first frame of the tag and continue playing. If not playing - only moves the playhead to the first frame of the tag.

sprite.currentTag = null; // Reset the current tag. Will play from the very first to the very last frame of the animation
```

Control the playback direction

```haxe
import ase.AnimationDirection;

// <...>

sprite.direction = AnimationDirection.FORWARD; // Play from the first frame to the last one
sprite.direction = AnimationDirection.REVERSE; // Play from the last frame to the first one
sprite.direction = AnimationDirection.PING_PONG; // Play the animation back and forth

/**
  It's not necessary to use the constants from the `AnimationDirection` class. You can use integers instead:

  FORWARD = 0
  REVERSE = 1
  PING_PONG = 2
 **/
```

**NOTE**: Will override the playback direction of the current tag

## Dox Documentation

From the project's directory:

```bash
$ cd scripts
$ haxe doc.hxml
```

HTML documentation fill be generated in the `documentation` directory in the project's directory

## Author

Michael Miriti

- email: m.s.miriti@gmail.com
- github: https://github.com/miriti
- twitter: https://twitter.com/michael_miriti

## License

This project is licensed under the MIT License - see [LICENSE.md](LICENSE.md) for details
