# Gesture

With the "animation" section above, we are already able to show some animations like enter-page transition even when the frame is very janky. However, what if the user interacts with the UI, such as dragging the ListView? *Without* the implementation in this section, the `PointerMoveEvent` will not be handled at all during a janky frame, because event handling happens between frames, so the preempt will render identical content in each scene. Thus, the user still feels the UI is freezed during a janky frame, even though it is 60FPS. This section is to solve the problem.

## How to get events

Quite simple - just "peek" from the engine. More specifically, whenever Flutter engine receives a (raw) pointer event from OS, it is enqueued to a peek queue. Then, at suitable time such as before preempt, we dequeue them and dispatch them.

## How to dispatch events

(Refer to source code of `GestureBinding._handlePointerEventImmediately` for this part.)

### `PointerDownEvent` and so on

:::info

This only occurs for a small portion of frames. Most frames will have `PointerMoveEvent` or no finger.

:::

Indeed we cannot do that. This is because, for a "down" event, it needs to go through the `hitTest` besides `dispatchEvent`. However, to `hitTest` something in the auxiliary tree, it must pass through `RenderObject`s in the main tree. As we know, those `RenderObject`s in the main tree are dirty since we are in the *middle* of build and layout phase, so we should not call `hitTest` on them.

However, this will not cause jank at all, because the "brake" mechanism discussed before solves the problem.

### `PointerMoveEvent` and so on

By looking at source code, we know it will merely go through a `dispatchEvent`. If a `RenderObject` inside auxiliary tree registers its interest in a pointer, it will *directly* get called during dispatch, without the need to touch other `RenderObject`s - unlike `PointerDownEvent`. That is perfect for our use case. We can simply go through the `dispatchEvent` routine (and make a simple filter so only call those RenderObjects in auxiliary tree), and will not need to interact with dirty main tree RenderObjects.


## Deliberately delay 1 frame

TODO https://github.com/fzyzcjy/yplusplus/issues/6066
