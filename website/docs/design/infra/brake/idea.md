# Idea

Now comes the solution in the third row of the figure (in the last section). 

When the event occurs, we realize it and triggers a brake. When doing so, the build and layout of the main tree will halt as fast as possible, by putting a placeholder widget instead of doing the real (and heavy) build or layout. Therefore, the main janky frame is quickly halted, and now there is a chance for ListView to handle the event, since its RenderObject is now non-dirty and we are in a normal between-frame event handling stage. After the event is handled (and other between-frame things are done), the next frame is started immediately. As long as it is started before 2.9 in the figure (i.e. have a few milliseconds before deadline), we can trigger a preempt render, so no jank will happen.

Remark: The empty space around 2.0-2.5 in the figure is because, there are some extra things to do by Flutter between two frames. However, it does not matter as long as such extra thing do not occupy about 16ms.

## Implementation details

To correctly implement it, there are some other details as well:

* Skip potential preempt render in build/layout phase and PostDrawFrame phase. Otherwise, we will submit too many scenes to rasterizer.
* Immediately start next frame (in the figure example, it starts around 2.5), as if it should have started earlier (in the example, as if it should have started at 2), instead of starting it in the next vsync. Otherwise, as can be seen in the figure, if the next frame starts at 3 not 2.5, then there is no chance to submit a preempt render around 2.9, so we will jank one frame.

