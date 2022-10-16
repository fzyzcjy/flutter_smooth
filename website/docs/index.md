---
title: Flutter Smooth
hide_title: true
---

import ReactPlayer from 'react-player'

![logo](https://raw.githubusercontent.com/fzyzcjy/flutter_smooth_blob/master/meta/logo.svg)

Achieve 60 FPS, no matter how heavy the tree is to build/layout

## Video in 3 seconds

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
        <small>(left = plain, right = smooth; captured by external camera to maximally demonstrate end-user perception)</small>
    </div>
    <div className="flex-1"></div>
</div>


## How to use it?

* **Drop-in replacements**: For common scenarios, add 6 characters ("Smooth") - `ListView` becomes [`SmoothListView`](usage/drop-in), ``MaterialPageRoute`` becomes [`SmoothMaterialPageRoute`](usage/drop-in).

* **Arbitrarily flexible builder**: For complex cases, use [`SmoothBuilder(builder: ...)`](usage/builder) and put the tree that you want to be smooth inside the `builder`.

## What will you get?

* No matter how heavy the tree is to build/layout, it will run at (roughly) [full FPS](benchmark/analyze/fps), [feel smooth](benchmark/analyze/linearity), [has zero uncomfortable janks](benchmark/analyze/jank-statistics), with [neglitable overhead](benchmark/analyze/overhead).

