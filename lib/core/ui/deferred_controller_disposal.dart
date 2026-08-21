import 'package:flutter/widgets.dart';

/// Disposes text controllers after the dialog route has completed its frame.
///
/// A dialog may finish [showDialog] before its TextField subtree is fully
/// removed. Waiting for the next frame prevents the field from trying to add
/// a listener to a controller that was disposed too early.
Future<void> disposeTextControllersAfterDialog(
  Iterable<TextEditingController> controllers,
) async {
  await Future<void>.delayed(Duration.zero);
  await WidgetsBinding.instance.endOfFrame;
  for (final controller in controllers) {
    controller.dispose();
  }
}
