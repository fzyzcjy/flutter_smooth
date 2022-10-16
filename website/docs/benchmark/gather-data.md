# Gather data

## Testing device

All tests are done in a TRT-AL00 Android device, with Snapdragon 435.

How slow is it? [Geekbench](https://nerdschalk.com/huawei-enjoy-7-plus-benchmarks-now-available/) says it is 642 & 2867 points (single & multi core, respectively). Another rough but intuitive viewpoint is by looking at [comments](https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onReportTimings.html) on `onReportTimings` - Flutter officially says it takes <0.1ms on iPhone6S per second, while I have measured ~20ms per second. <!-- #6127 -->

## Record video

To get most real results, I use the camera of a *second* phone to record a video of the testing device. For example:

[![gather_data_raw_video](../../../blob/doc_images/gather_data_raw_video.png)](https://github.com/fzyzcjy/flutter_smooth_blob/blob/master/video/list_view/raw_smooth.mp4)

After getting a video (e.g. `.mp4`), the following commands can be utilized to break it into frames. Each frame will become a photo (`.jpg`), and a timestamp extracted from the video intrinsitc information is added to the left-top corner of the extracted frame.

```shell
ffmpeg -i path/to/your/video.mp4 -vsync 0 -frame_pts true -vf drawtext=fontfile=/usr/share/fonts/truetype/freefont/FreeMonoBold.ttf:fontsize=80:text='%{pts}':fontcolor=white@0.8:x=7:y=7 ~/temp/video_frames/output_%04d.jpg
```

(The `video_to_frame.py` does the same job as the command above.)

For example, the result is:

![gather_data_video_frames](../../../blob/doc_images/gather_data_video_frames.png)

Why use a second camera: If we use screen recording on the testing device, it can bias the result because the recording itself takes CPU and GPU. Moreover, the recorded screen may not be equivalent to what a user really percepts by eyes.

:::info

When debugging raw videos, it may be helpful to add some small headers that change its content to a great extent in every frame, such as [this one](https://github.com/fzyzcjy/flutter_smooth/blob/4920f6fa00ef856f238554bbdd2ec2b44e6b54b7/packages/smooth/example/lib/example_list_view/example_list_view_page.dart#L263). With that, we can easily spot, for example, whether there is really a jank (when the debug header is unchanged in two sibling video frames) or a bug in scrolling logic (when the header changes in two sibling frames but the ListView content is not shifted).

:::

## Record timeline tracing

I also record the timeline tracing data, which provide rich insights. 

1. Run with endless tracing buffer, i.e. with `--endless-trace-buffer` flag. For example, `flutter run --profile --endless-trace-buffer`.
2. Perform all interactions with the app.
3. Tap `v` in the shell to open DevTool.
4. Tap [download](https://docs.flutter.dev/development/tools/devtools/performance#import-and-export) in DevTool panel to get somthing like `dart_devtools_2022-10-16_09_54_55.141.json`.
5. The file can be opened in `chrome://tracing`.

We will use automatic scripts later to enhance it.

:::tip

Must perform all interactions **before** (not after) opening DevTool. Empirically, I observe large performance drop after DevTool is opened.

:::

Sample result:

![](../../../blob/doc_images/gather_data_tracing_example.png)


