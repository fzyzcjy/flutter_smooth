# Result from video

## Methods

Look at each frame of the video. If a frame has identical content as the previous frame, we consider it as a jank.

In addition, even though the content is unchanged, if it is because the user really have zero pointer speed (e.g. when the finger reaches the top/bottom of screen), this is not a jank. To identify such cases from the classical janks, either by common sense, or use the "debug header" trick discussed in "gather-data" section to confirm.

There seems to be one jank that also happens in classical Flutter, even when content is super fast to compute, so we need to exclude (or at least consider) this effect from our computation. This is the jank that occurs when pointer up. See https://github.com/flutter/flutter/issues/113494 for details.

## Results

:::info

Some bugs in this package are not fixed yet, so the following result is only >58FPS. Theoretically, it should be 60FPS.

:::

Looking at the sample captured video 0023.jpg - 0181.jpg, we see some frames having identical content as previous:

* Some are false positives since user really has zero speed: 0041.jpeg, 0055.jpeg, 0056.jpeg, 0070.jpeg, 0071.jpeg, 0087.jpeg
* Some look like real jank, except one for the pointer-up-jank also happened in classical Flutter: 0091.jpeg, 0093.jpeg, 0097.jpeg, 0100.jpeg, 0102.jpeg.

Therefore, the FPS is **58.5** (excluding the classical-Flutter problem) or **58.1** (including that problem).

As can be seen in the raw video, it seems that human eyes almost do not percept these. On the other hand, this package is still quite buggy (though I have fixed a lot), and I have seen many bugs causing wrong timing and thus cause jank. So please come back later to see if the package is bug-fixed. Last but not least, some janks are not in the scope that this package aim to solve, for example, when (I suspect) the OS is busy with something else, or when a slow GC happens (I do see weird young-generation GC for 20ms sometimes but has not investigated it).

Jank sample frame (the highlighted one):

![](../../../../../blob/doc_images/video_jank_sample.png)