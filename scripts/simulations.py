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


@dataclass
class ClampingScrollSimulation:
    position: float
    velocity: float
    friction: float = 0.015

    def __init__(self):
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
