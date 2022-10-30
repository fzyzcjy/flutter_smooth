<!-- start: title -->

# [flutter_smooth](https://github.com/fzyzcjy/flutter_smooth/tree/master)

<!-- end: title -->

![logo](https://raw.githubusercontent.com/fzyzcjy/flutter_smooth_blob/master/meta/logo.svg)

<center><small>Achieve ~60 FPS, no matter how heavy the tree is to build/layout.</small></center>

## 🎼 3-second video

<!-- start: video -->

https://user-images.githubusercontent.com/5236035/196152010-09a2d829-c94c-48b4-80ed-0633430329ec.mp4

<small><small>(left = without smooth, right = smooth; captured by external camera to maximally demonstrate end-user perception. High-resolution video [here](https://fzyzcjy.github.io/flutter_smooth).)</small></small>

<!-- end: video -->

## 📚 1-minute explanation

### Purpose

No matter how heavy the tree is to build/layout, it will run at (roughly) full FPS, feel smooth, has zero uncomfortable janks, with negligible overhead. (Detailed reports [here](https://fzyzcjy.github.io/flutter_smooth/benchmark))

### Usage

Two possibilities:

* **Drop-in replacements**: For common scenarios, add 6 characters ("Smooth") - `ListView` becomes `SmoothListView`, ``MaterialPageRoute`` becomes `SmoothMaterialPageRoute`.

* **Arbitrarily flexible builder**: For complex cases, use `SmoothBuilder(builder: ...)` and put whatever you want to be smooth inside the `builder`.

## 🚀 What's next

The documentation - https://fzyzcjy.github.io/flutter_smooth/, with usage, demo, benchmark, insights, and more.

> **Note**
> Feel free to create an [issue](https://github.com/fzyzcjy/flutter_smooth/issues) if you have any questions/problems. I usually reply quickly within minutes if not hours, except for sleeping :)

## Contributors

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key) following [all-contributors](https://github.com/all-contributors/all-contributors) specification):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://github.com/fzyzcjy"><img src="https://avatars.githubusercontent.com/u/5236035?v=4?s=100" width="100px;" alt="fzyzcjy"/><br /><sub><b>fzyzcjy</b></sub></a><br /><a href="https://github.com/fzyzcjy/flutter_smooth/commits?author=fzyzcjy" title="Code">💻</a> <a href="https://github.com/fzyzcjy/flutter_smooth/commits?author=fzyzcjy" title="Documentation">📖</a> <a href="#ideas-fzyzcjy" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="http://ln.hixie.ch/"><img src="https://avatars.githubusercontent.com/u/551196?v=4?s=100" width="100px;" alt="Ian Hickson"/><br /><sub><b>Ian Hickson</b></sub></a><br /><a href="#ideas-Hixie" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="https://github.com/dnfield"><img src="https://avatars.githubusercontent.com/u/8620741?v=4?s=100" width="100px;" alt="Dan Field"/><br /><sub><b>Dan Field</b></sub></a><br /><a href="#ideas-dnfield" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="https://github.com/jonahwilliams"><img src="https://avatars.githubusercontent.com/u/8975114?v=4?s=100" width="100px;" alt="Jonah Williams"/><br /><sub><b>Jonah Williams</b></sub></a><br /><a href="#ideas-jonahwilliams" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="https://github.com/gaaclarke"><img src="https://avatars.githubusercontent.com/u/30870216?v=4?s=100" width="100px;" alt="gaaclarke"/><br /><sub><b>gaaclarke</b></sub></a><br /><a href="#ideas-gaaclarke" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="https://juejin.cn/user/4309694831660711"><img src="https://avatars.githubusercontent.com/u/40540394?v=4?s=100" width="100px;" alt="Nayuta403"/><br /><sub><b>Nayuta403</b></sub></a><br /><a href="https://github.com/fzyzcjy/flutter_smooth/commits?author=Nayuta403" title="Documentation">📖</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

More specifically, thanks for all these contributions:

* [@Hixie](https://github.com/Hixie) (Flutter team): Consider details of my several proposals to the Flutter framework/engine such as requiring zero-overhead principle. Construct concrete cases when the initial proposal becomes fragile.
* [@dnfield](https://github.com/dnfield) (Flutter team): Provide a canonical janky case inside Flutter framework to help prototyping. Point out slowness of sync generators which avoids detouring.
* [@jonahwilliams](https://github.com/jonahwilliams) (Flutter team): Elaborate shortcomings of the old gesture system proposal (later I made a much more natural one).
* [@gaaclarke](https://github.com/gaaclarke) (Flutter team): Share his pet theory that slowness is caused by memory locality, indicating another potential application of the package.
* [@Nayuta403](https://github.com/Nayuta403): Fix link.

