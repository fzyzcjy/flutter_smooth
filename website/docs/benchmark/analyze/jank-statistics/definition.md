# Definition

Not all janks are equivalent to user eyes. A one-frame jank may not be percepted, while freezing the UI for 3 or 5 frames may be very annoying. There are even [some](https://perfdog.wetest.net/article_detail?id=20&issue_id=0&plat_id=1) fancy methods to calculate user-percepted janks.

We simply consider the following metrics:

1. Trivial janks: The one-frame janks.
2. Nontrivial janks: Any jank that last for more than one frame is considered as nontrivial. Moreover, the longer one single jank lasts, the worse user may feel.
3. Longest jank: The maximum lasting time for a single jank.

