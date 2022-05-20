import 'package:flutter/widgets.dart';
import 'package:footage/src/core/context_extensions.dart';
import 'package:footage/src/core/time.dart';

import 'providers.dart';

/// All child animation considers the time freezed to the given [time].
class Freeze extends StatelessWidget {
  const Freeze({
    Key? key,
    required this.child,
    required this.time,
  }) : super(key: key);

  final Widget child;
  final Time time;

  @override
  Widget build(BuildContext context) {
    final config = context.video.config;
    final frame = time.asFrames(config.durationInFrames, config.fps);
    return CurrentFrameProvider(
      frame: frame,
      child: child,
    );
  }
}
