import 'package:flutter/widgets.dart';
import 'package:footage/src/core/sequence.dart';
import 'package:footage/src/core/time.dart';

import 'context_extensions.dart';
import 'freeze.dart';
import 'markers.dart';

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

    Widget? result;
    final markers = <Marker>[];

    var from = 0;
    for (var child in children) {
      final childDurationInFrames =
          child.duration.asFrames(config.durationInFrames, config.fps);
      from += child.offset.asFrames(config.durationInFrames, config.fps);
      if (frame >= from && (from + childDurationInFrames > frame)) {
        final sequence = Sequence(
          name: child.name,
          from: Time.frames(from),
          duration: Time.frames(childDurationInFrames),
          freezeAfter: child.freezeAfter,
          freezeBefore: child.freezeBefore,
          child: child.child,
        );

        result = sequence;
      }
      final marker = child.marker;
      if (marker != null) {
        markers.add(
          marker.toMarker(Time.frames(from)),
        );
      }
      from += childDurationInFrames;
    }

    if (markers.isNotEmpty) {
      return Markers(
        markers: markers,
        child: result ?? const SizedBox(),
      );
    }

    return result ?? const SizedBox();
  }
}

class SeriesSequence {
  const SeriesSequence({
    required this.child,
    required this.duration,
    this.offset = const Time.frames(0),
    this.marker,
    this.name,
    this.freezeBefore = false,
    this.freezeAfter = false,
  });

  final String? name;
  final Time offset;
  final Time duration;
  final Widget child;
  final bool freezeAfter;
  final bool freezeBefore;
  final SeriesMarker? marker;
}

class SeriesMarker {
  const SeriesMarker(
    this.name, {
    this.color = Marker.defaultColor,
  });

  final String name;
  final Color color;

  Marker toMarker(Time at) {
    return Marker(
      at,
      name,
      color: color,
    );
  }
}
