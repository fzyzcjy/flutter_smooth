# Devtool

We cannot view the (computed) metrics of devtool because of the following reasons.

1. We disabled the timing report (which takes several milliseconds on my testing device), so DevTool has no data source.
2. DevTool does not understand our scheme perfectly, so it has the wrong timing data even if it is enabled.
3. It is inaccurate. Please see https://github.com/flutter/devtools/issues/4522 and [this pitfall](../../pitfall/half-fps) for details.

Instead, please use the methods discussed in previous sections to see the FPS.
