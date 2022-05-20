import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:footage/src/preview/controller.dart';

class PreviewActions extends StatelessWidget {
  const PreviewActions({
    super.key,
    required this.child,
    required this.controller,
  });
  final PreviewFootageController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowLeft):
            const PreviousFrameActionIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const PreviewActionIntent(),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowRight):
            const NextFrameActionIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft):
            const GoToPreviousMarkerActionIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight):
            const GoToNextMarkerActionIntent(),
      },
      child: Actions(
        actions: {
          PreviewActionIntent: CallbackAction<PreviewActionIntent>(
            onInvoke: (intent) => controller.togglePlay(),
          ),
          NextFrameActionIntent: CallbackAction<NextFrameActionIntent>(
            onInvoke: (intent) => controller.nextFrame(),
          ),
          PreviousFrameActionIntent: CallbackAction<PreviousFrameActionIntent>(
            onInvoke: (intent) => controller.previousFrame(),
          ),
          GoToPreviousMarkerActionIntent:
              CallbackAction<GoToPreviousMarkerActionIntent>(
            onInvoke: (intent) => controller.goToPreviousMarker(),
          ),
          GoToNextMarkerActionIntent:
              CallbackAction<GoToNextMarkerActionIntent>(
            onInvoke: (intent) => controller.goToNextMarker(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

class PreviewActionIntent extends Intent {
  const PreviewActionIntent();

  static void invoke(BuildContext context) {
    Actions.maybeInvoke<PreviewActionIntent>(
      context,
      const PreviewActionIntent(),
    );
  }
}

class NextFrameActionIntent extends Intent {
  const NextFrameActionIntent();

  static void invoke(BuildContext context) {
    Actions.maybeInvoke<NextFrameActionIntent>(
      context,
      const NextFrameActionIntent(),
    );
  }
}

class PreviousFrameActionIntent extends Intent {
  const PreviousFrameActionIntent();

  static void invoke(BuildContext context) {
    Actions.maybeInvoke<PreviousFrameActionIntent>(
      context,
      const PreviousFrameActionIntent(),
    );
  }
}

class GoToNextMarkerActionIntent extends Intent {
  const GoToNextMarkerActionIntent();

  static void invoke(BuildContext context) {
    Actions.maybeInvoke<GoToNextMarkerActionIntent>(
      context,
      const GoToNextMarkerActionIntent(),
    );
  }
}

class GoToPreviousMarkerActionIntent extends Intent {
  const GoToPreviousMarkerActionIntent();

  static void invoke(BuildContext context) {
    Actions.maybeInvoke<GoToPreviousMarkerActionIntent>(
      context,
      const GoToPreviousMarkerActionIntent(),
    );
  }
}
