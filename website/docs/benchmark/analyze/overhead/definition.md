# Definition

The overhead is the wasted time compared to a perfect solution. More specifically, suppose there exists a perfect solution that can make your real-world app render at 60FPS. Then, we measure the time of that perfect solution (suppose it is 1.00s) as well as the time if using this package (suppose it is 1.01).  Then, we say the overhead is (1.01-1.00)/1.00 = 1%.

Notice that, it seems not reasonable to simply compare the time using this package with the time for vanilla app. This is because the (non-existent) "perfect solution" must be slower than the vanilla app, so this part of time delta is not overhead. That time delta are necessary, since it has to generate extra frames, by whatever means, in order to achieve the 60FPS goal.

