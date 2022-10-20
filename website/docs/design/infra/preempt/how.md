# How to trigger

By normal function call. The psuedo simplified core code looks like:

```dart
// you know, the workhorse in layout phase
void performLayout() {
  if (shouldTriggerPreempt) preemptRender();
  ...original code...
}
```

As for implementation details, I create `PreemptPoint` widgets which does this check at build and layout time. An alternative solution, if Flutter merges my PR, is to inject this if-clause into `RenderObject.performLayout`.

If you are familiar with the prior approaches (discussed in literature review), this may need a bit of time to grasp. In prior approaches, *early return* is utilized (i.e. `if (nearDeadline) return; else doHeavyJob();`), and the main thread finally has zero call stack depth. However, to the contrary, this approach only *calls* a normal function.