# Definition

Consider the case of ListView scrolling by inertia. Even if it is 60FPS, it can still be uncomfortable for the users if the shifting amount changes abruptly instead of smoothly. For example, if in frame 1 it shifts 20px, but in frame 2 it shifts 5px and frame 3 for 35px, the user will feel a weird jump.

A real world case is that, the [latency decrease](pitfall/latency-change) will cause such a uncomfortable "jump".

As for this concrete benchmark case, there are two parts: In the first part, the ListView is scrolled by user `PointerMoveEvent`s, so the perfect case is that it follows the user pointer events (up to some OS touch system latency). In the second part, the ListView goes through a ballistic animation, i.e. gradually slow down shifting. The perfect result should follow the `Simulation` curve.
