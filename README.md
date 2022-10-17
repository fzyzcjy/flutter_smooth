<!-- start: title -->
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

# [flutter_smooth](https://github.com/fzyzcjy/flutter_smooth/tree/master)

<!-- end: title -->

![logo](https://raw.githubusercontent.com/fzyzcjy/flutter_smooth_blob/master/meta/logo.svg)

<center><small>Achieve 60 FPS, no matter how heavy the tree is to build/layout.</small></center>

## 3-second video

<!-- start: video -->

https://user-images.githubusercontent.com/5236035/196115059-5b32622b-bfc3-4f81-9f49-f7c6bd8c9c0f.mp4

<small><small>(left = without smooth, right = smooth; captured by external camera to maximally demonstrate end-user perception. High-resolution video [here](https://fzyzcjy.github.io/flutter_smooth).)</small></small>

<!-- end: video -->

## Purpose

No matter how heavy the tree is to build/layout, it will run at (roughly) full FPS, feel smooth, has zero uncomfortable janks, with neglitable overhead. (Detailed reports [here](benchmark))

## Usage

Two possibilities:

* **Drop-in replacements**: For common scenarios, add 6 characters ("Smooth") - `ListView` becomes [`SmoothListView`](https://fzyzcjy.github.io/flutter_smooth/usage/drop-in), ``MaterialPageRoute`` becomes [`SmoothMaterialPageRoute`](https://fzyzcjy.github.io/flutter_smooth/usage/drop-in).

* **Arbitrarily flexible builder**: For complex cases, use [`SmoothBuilder(builder: ...)`](https://fzyzcjy.github.io/flutter_smooth/usage/builder) and put whatever you want to be smooth inside the `builder`.

## Status

* The infra part is already implemented (hard, took me a month). The drop-in part and demo, which is mainly engineering work utilizing the exposed infra API, still has many improveable things - feel free to issue and PR!
* Need to wait for all PRs to Flutter to be merged and next Flutter release. (PR status [here](https://fzyzcjy.github.io/flutter_smooth/insight/status))

## Contributors

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://github.com/fzyzcjy"><img src="https://avatars.githubusercontent.com/u/5236035?v=4?s=100" width="100px;" alt="fzyzcjy"/><br /><sub><b>fzyzcjy</b></sub></a><br /><a href="https://github.com/fzyzcjy/flutter_smooth/commits?author=fzyzcjy" title="Code">💻</a> <a href="https://github.com/fzyzcjy/flutter_smooth/commits?author=fzyzcjy" title="Documentation">📖</a> <a href="#ideas-fzyzcjy" title="Ideas, Planning, & Feedback">🤔</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
[![All Contributors](https://img.shields.io/badge/all_contributors-13-orange.svg?style=flat-square)](#contributors)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## Thanks

* [@Hixie](https://github.com/Hixie) (Flutter team): Consider details of my several proposals to the Flutter framework/engine such as requiring zero-overhead principle. Construct concrete cases when the initial proposal becomes fragile.
* [@dnfield](https://github.com/dnfield) (Flutter team): Provide a canonical janky case inside Flutter framework to help prototyping. Point out slowness of sync generators which avoids detouring.
* [@jonahwilliams](https://github.com/jonahwilliams) (Flutter team): Elaborate shortcomings of the old gesture system proposal (later I made a much more natural one).
* [@gaaclarke](https://github.com/gaaclarke) (Flutter team): Share his pet theory that slowness is caused by memory locality, indicating another potential application of the package.

