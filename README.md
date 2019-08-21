# OpenFL Aseprite

Load and render sprites and animations in Aseprite format. Based on [ase](https://github.com/miriti/ase) library.

## Installation

1. Install the library via `haxelib`:

```
haxelib install openfl-aseprite
```

2. Add this line to the `project.xml` file:

```xml
 <haxelib name="openfl-aseprite" />
```

## Usage

The main class of the library (`ase.AsepriteSprite`) extends `openfl.display.Sprite` so you can use it just like any other OpenFL sprite.

To create an `AsepriteSprite` pass `Bytes` of an .ase/.aseprite file to its constructor:

```haxe
import ase.AsepriteSprite;
import openfl.Assets;

// <...>

var data:Bytes = Assets.getBytes('path/to/asepriteAsset.aseprite');
var masked:Bool = true;
var backgroundColor:Int = 0xcccccc;
var sprite:AsepriteSprite = new AsepriteSprite(data, masked, backgroundColor);

addChild(sprite);
```

The constructor has two optional parameters:

- `masked` - if set to `true` a mask will be added to the sprite to hide any content outsize of the sprite's boundaries
- `backgroundColor` - if set will add rectangle of the size of the sprite to the background

### `AsepriteSprite` class properties

#### `aseprite`

An instance of the `ase.Aseprite` class

#### `currentFrame`

Current frame of the animation

#### `duration` (read-only)

Duration of the animation in milliseconds

#### `frames`

Array of frames

#### `layers`

Array of layers

#### `loop`

Whether the animation should be looped or played once

#### `time`

Current time of the animation in milliseconds. Setting this property will automatically show the appropriate frame on the timeline

#### `useEnterFrame` (default `true`)

If set to `true` will use `Event.ENTER_FRAME` event to progress animation. Otherwise the `time` or `currentFrame` property should be updated

### `AsepriteSprite` class methods

#### `play()`

Play the animation

## TODO

- [ ] Tags
- [ ] Slices
- [ ] Color profile
- [ ] Support all the bland modes

## Authors

- Michael Miriti @miriti <m.s.miriti@gmail.com>

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
