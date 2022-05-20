import 'package:flutter/widgets.dart';
import 'package:footage/src/core/sequence.dart';
import 'package:footage/src/core/time.dart';

import 'context_extensions.dart';

class Series extends StatelessWidget {
  const Series({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<SeriesSequence> children;

  @override
  Widget build(BuildContext context) {
    final frame = context.video.currentFrame;
    final config = context.video.config;

    var from = 0;
    for (var child in children) {
      final childDurationInFrames =
          child.duration.asFrames(config.durationInFrames, config.fps);
      from += child.offset.asFrames(config.durationInFrames, config.fps);
      if (frame >= from && (from + childDurationInFrames > frame)) {
        return Sequence(
          name: child.name,
          from: Time.frames(from),
          duration: Time.frames(childDurationInFrames),
          child: child.child,
        );
      }
      from += childDurationInFrames;
    }

    return const SizedBox();
  }
}

class SeriesSequence {
  const SeriesSequence({
    required this.child,
    required this.duration,
    this.name,
    this.offset = const Time.frames(0),
  });

  final String? name;
  final Time offset;
  final Time duration;
  final Widget child;
}
