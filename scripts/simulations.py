import matplotlib
import numpy as np

matplotlib.use("MacOSX")

import matplotlib.pyplot as plt

import math
from dataclasses import dataclass

_kDecelerationRate = math.log(0.78) / math.log(0.9)
_initialVelocityPenetration = 3.065


def _decelerationForFriction(friction: float):
    return friction * 61774.04968


def _flingDistancePenetration(t):
    return (1.2 * t * t * t) - (3.27 * t * t) + (_initialVelocityPenetration * t)


def _flingVelocityPenetration(t):
    return (3.6 * t * t) - (6.54 * t) + _initialVelocityPenetration


def clampDouble(x, min, max):
    if x < min:
        return min
    if x > max:
        return max
    return x


def _sign(x):
    if x > 0:
        return 1.0
    if x < 0:
        return -1.0
    return x


def _array_map(x, f):
    return np.fromiter((f(xi) for xi in x), x.dtype)


@dataclass
class ClampingScrollSimulation:
    position: float
    velocity: float
    friction: float = 0.015

    def __post_init__(self):
        self._duration = self._flingDuration(self.velocity)
        self._distance = abs(self.velocity * self._duration / _initialVelocityPenetration)

    def _flingDuration(self, velocity: float):
        scaledFriction = self.friction * _decelerationForFriction(0.84)
        deceleration = math.log(0.35 * abs(velocity) / scaledFriction)
        return math.exp(deceleration / (_kDecelerationRate - 1.0))

    def x(self, time):
        t = clampDouble(time / self._duration, 0.0, 1.0)
        return self.position + self._distance * _flingDistancePenetration(t) * _sign(self.velocity)

    def dx(self, time):
        t = clampDouble(time / self._duration, 0.0, 1.0)
        return self._distance * _flingVelocityPenetration(t) * _sign(self.velocity) / self._duration


# %%

plt.clf()
plt.tight_layout()
ax1 = plt.gca()
ax2 = ax1.twinx()

dt = 1 / 60
t = np.arange(0, 1, dt)

simulation_a = ClampingScrollSimulation(position=0, velocity=1000)
x_a = _array_map(t, simulation_a.x)
v_a = _array_map(t, simulation_a.dx)
diffx_a = (x_a[1:] - x_a[:-1]) / dt

ax1.plot(t, x_a, label='x_a')
ax2.plot(t, v_a, label='v_a')
ax2.plot(t[:-1], diffx_a, label='diffx_a')

if False:
    b_start_time = 0.3
    simulation_b = ClampingScrollSimulation(
        position=simulation_a.x(b_start_time),
        velocity=simulation_a.dx(b_start_time),
    )
    x_b = _array_map(t, simulation_b.x)
    v_b = _array_map(t, simulation_b.dx)
    diffx_b = (x_b[1:] - x_b[:-1]) / dt

    ax1.plot(t + b_start_time, x_b, label='x_b')
    ax2.plot(t + b_start_time, v_b, label='v_b')
    ax2.plot(t[:-1] + b_start_time, diffx_b, label='diffx_b')

ax1.legend(loc="upper left")
ax2.legend(loc="upper right")

plt.xlim([0, 1])

plt.show()
