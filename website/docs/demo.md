# Demo

The `packages/smooth/example` is a demo that can be run as a normal Flutter app.

Warn: This demo contains a *ton* of bugs and counter-intuitive UX. Since the package is quite challenging to implement, I devoted most of my time to the infra layer (a month indeed), and does not have time yet to improve these. I plan to fix some of the hard ones when I PR to Flutter.

Currently, I only focused on (1) scroll down in ListView demo (2) enter-page in PageTransition demo. For example, leave-page will not be smooth, because I have not implemented that - but as you can guess, it is trivial to enhance the `SmoothMaterialPageRoute` such that it knows *leave*-page animations given the existing *enter*-page animations.

:::info

To make this package work, some PRs needs to be merged to `flutter/flutter` and `flutter/engine`. Before that, a custom framework and engine build are needed: https://github.com/fzyzcjy/flutter/tree/flutter-smooth and https://github.com/fzyzcjy/engine/tree/flutter-smooth.

:::