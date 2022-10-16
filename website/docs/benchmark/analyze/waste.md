# Waste

You may sometimes see synthesized events called `Waste(MultiRasterEndInVsyncInterval)` and `Waste(NoPendingContinuation)`. They do not indicate any user-visible problems. Instead, they are purely hints that may be necessary and is the correct thing, while sometimes may reveal deeper bug. Feel free to ping me when you see it and feel like it reveals something is going wrong.

`Waste(MultiRasterEndInVsyncInterval)` means that, there are multiple rasterizer ending at one vsync interval, such that all except the last output will be thrown away.

`Waste(NoPendingContinuation)` means that, the queue is full so `window.render` call is directly thrown away.
