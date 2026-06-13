import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reports the rendered size of [child] via [onChange] whenever it changes.
///
/// Unlike `LayoutBuilder` (which exposes incoming constraints, not intrinsic
/// size), this measures the child's actual laid-out size. The callback is
/// deferred to a post-frame callback so listeners can safely mutate state
/// (e.g. a store observable) without triggering a build-phase mutation.
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _MeasureSizeRenderObject).onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;

    // Defer out of the layout phase so the callback can mutate observed state.
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
