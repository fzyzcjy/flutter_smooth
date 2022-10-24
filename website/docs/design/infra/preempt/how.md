# How to trigger

By normal function call. The psuedo simplified core code looks like:

```dart
// you know, the workhorse in layout phase
void performLayout() {
  if (shouldTriggerPreempt()) preemptRender();
  ...original code...
}

bool shouldTriggerPreempt() => /* will discuss in next sections */
void preemptRender() => /* will discuss in next sections */
```

## Implementation details

As for implementation details, I create `PreemptPoint` widgets which does this "should trigger preempt" check at build and layout time. An alternative solution, if Flutter merges my PR, is to inject this if-clause into `RenderObject.performLayout`, so users do not need to manually do anything.

## A small comparsion

If you are familiar with the prior approaches (discussed in literature review), this may need a bit of time to grasp. In prior approaches, *early return* is utilized, such as the following pseudo code:

```dart
void performLayout() {
  if (nearDeadline()) return;
  somehow_continue_from_last_early_return;
  ...original code...
}
```

In those approaches, the main thread finally has zero call stack depth. However, to the contrary, this approach only *calls* a normal function.