// ignore_for_file: prefer_initializing_formals

import 'package:flutter/widgets.dart';

import 'config.dart';
import 'context_extensions.dart';
import 'providers.dart';
import 'time.dart';

/// Repeats all children animations during the given [duration].
///
/// When children are reading the configuration and current frame, they are
/// overriden to be relative to the loop iteration.
class Loop extends StatelessWidget {
  const Loop({
    super.key,
    required this.child,
    required this.duration,
    this.name,
  });

  final String? name;
  final Widget child;
  final Time duration;

  @override
  Widget build(BuildContext context) {
    final frame = context.video.currentFrame;
    final config = context.video.config;
    final durationInFrames =
        duration.asFrames(config.durationInFrames, config.fps);
    return VideoConfigProvider(
      config: VideoConfig(
        fps: config.fps,
        durationInFrames: durationInFrames,
        width: config.width,
        height: config.height,
      ),
      child: CurrentFrameProvider(
        frame: frame % durationInFrames,
        child: child,
      ),
    );
  }
}
