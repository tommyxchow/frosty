import 'package:flutter/material.dart';

/// Shows a modal bottom sheet that properly handles focus restoration.
///
/// This prevents Flutter from automatically restoring focus to text fields
/// after the sheet is dismissed by clearing the focus scope before opening.
Future<T?> showModalBottomSheetWithProperFocus<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  String? barrierLabel,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
}) {
  // Clear focus and its history so it can't be auto-restored
  FocusScope.of(context).unfocus();

  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
  ).whenComplete(() {
    // Additional safety: clear any focus that might have been restored
    if (context.mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  });
}
