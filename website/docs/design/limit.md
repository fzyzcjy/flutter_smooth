# Limitations

The package does not solve the following problems, because either they are seldom a real problem or they are being fixed by Flutter.

## Jank by paint

The package does not aim to solve jank caused by too-slow paint phase. This seems rarely to be a problem, because painting is usually pretty fast and is not the bottleneck. If you really observe super-slow paint, try to move some code from paint phase to build/layout phase. For example, instead of doing heavy computation about the location of a rectangle inside `CustomPainter.paint`,  try to do it inside `initState`/`didUpdateState`/`build` etc. If you still see problems, create an issue so we can discuss it.

## Jank by rasterizer

The jank caused by rasterizer slowness is also not a target. The reason is that, Flutter has an in-progress rewriting of rasterizer, called [Impeller](https://github.com/flutter/engine/tree/main/impeller), which solves the shader compilation jank (which is [reported](https://discord.com/channels/608014603317936148/608021234516754444/1021979601142034535) by ByteDance that, *most* raster janks are caused by this) and so on. In short, Flutter is already having a great in-progress job that solves most of this problem, and this is a completely different area.

