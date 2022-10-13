---
title: Pitfalls
---

### Undetected jank when latency changes

TODO: when latency=1->2/2->1, user also feels jank, but many FPS calculation methods do not realize this (#6114)

### FPS is 30 (not 59), when running with 16.67+0.01ms

TODO: common mistake - "average = 16.68ms" means 30FPS not 59FPS. even devtool is wrong.
