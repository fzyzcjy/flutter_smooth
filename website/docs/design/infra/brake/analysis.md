# Analysis

## Comparison

At a first glance, it looks a bit familiar with the "split heavy work into multi frames and early return in each frame" prior work. To fully understand this design, we need to notice their differences, mainly in the occasion when to trigger an early return:

In prior work, it is triggered unconditionally, after a portion of heavy work has been done (as long as we are discussing heavy-work frames). In brake, it is never triggered, unless preempt notices there are some events that it cannot handle within preempt render.

## Cost

Firstly, the amortized cost is very small. With the comparison above, we now clearly see why ths cost is minor, even though the prior work has many shortcomings. It is mainly because the frequency of triggering the mechanism. In prior work, the early return mechanism with all the cost are triggered on each and every 16.67ms (again assuming we are discussing heavy-work frames). However, in the brake, it is triggerred very sparsely. For the ListView scrolling example, only the pointer down and pointer up (the latter can be overcome indeed) needs to trigger brake. Suppose a scroll takes 2 second, then only 1/60 of the  scenarios trigger brake, so the amortized cost is very tiny if not neglitable.

Secondly, consider the frame that has the worst cost, it is still no problem. If the brake is alone, we do face the risk of jank. For example, just like prior work, if we miss the deadline by even 0.01ms, then we will face one jank, and as discussed earlier, such probablity is inevitable. However, the brake is not alone, but accompanied with the preempt. Thus, it has much looser timing requirements - as long as we start a new frame *a few* milliseconds before the deadline, we are safe and no jank will happen. For a concrete example, in the third row of the figure, even if the second frame starts at (e.g.) time 2.8, there is still no jank.