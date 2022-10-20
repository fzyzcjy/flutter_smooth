# Introduction

In this chapter, I will discuss how this package is designed and implemented.

## The layers

The package mainly consists of two layers:

1. Infra layer: The core logic. Only expose a few low-level flexible primitives such as `SmoothBuilder` to the outside world.
2. Drop-in layer: Code in this layer utilizes the infra layer to build drop-in replacement solutions, such as `SmoothListView`. This section also serves as examples when you want to create your own drop-in replacement (e.g. when you want to create `SmoothMyFancyGridView`).
