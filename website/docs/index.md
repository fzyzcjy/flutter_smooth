---
title: Flutter Smooth
hide_title: true
---

import ReactPlayer from 'react-player'

![logo](https://raw.githubusercontent.com/fzyzcjy/flutter_smooth_blob/master/meta/logo.svg)

<center><small>Achieve 60 FPS, no matter how heavy the tree is to build/layout.</small></center>

## 3-second video

<div className="flex flex-row">
    <div className="flex-1"></div>
    <div className="flex" style={{flexDirection: 'column', alignItems: 'center'}}>
        <ReactPlayer 
            controls
            className="flex"
            width="480px"
            height="320px"
            url='https://github.com/fzyzcjy/flutter_smooth_blob/blob/master/video/output.mp4?raw=true'
        />
        <small>(left = without smooth, right = smooth; captured by external camera to maximally demonstrate end-user perception)</small>
    </div>
    <div className="flex-1"></div>
</div>

## Purpose

No matter how heavy the tree is to build/layout, it will run at (roughly) full FPS, feel smooth, has zero uncomfortable janks, with neglitable overhead. (Detailed reports [here](benchmark))

## Usage

Two possibilities:

* **Drop-in replacements**: For common scenarios, add 6 characters ("Smooth") - `ListView` becomes [`SmoothListView`](usage/drop-in), ``MaterialPageRoute`` becomes [`SmoothMaterialPageRoute`](usage/drop-in).

* **Arbitrarily flexible builder**: For complex cases, use [`SmoothBuilder(builder: ...)`](usage/builder) and put whatever you want to be smooth inside the `builder`.

## Status

* The infra part is already implemented (hard, took me a month). The drop-in part and demo, which is mainly engineering work utilizing the exposed infra API, still has many improveable things - feel free to issue and PR!
* Need to wait for all PRs to Flutter to be merged and next Flutter release. (PR status [here](insight/status))

## Thanks

* [@Hixie](https://github.com/Hixie) (Flutter team): Consider details of my several proposals to the Flutter framework/engine such as requiring zero-overhead principle. Construct concrete cases when the initial proposal becomes fragile.
* [@dnfield](https://github.com/dnfield) (Flutter team): Provide a canonical janky case inside Flutter framework to help prototyping. Point out slowness of sync generators which avoids detouring.
* [@jonahwilliams](https://github.com/jonahwilliams) (Flutter team): Elaborate shortcomings of the old gesture system proposal (later I made a much more natural one).
* [@gaaclarke](https://github.com/gaaclarke) (Flutter team): Share his pet theory that slowness is caused by memory locality, indicating another potential application of the package.
