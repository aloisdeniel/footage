import 'package:flutter/material.dart';

import 'config.dart';
import 'providers.dart';

extension VideoExtension on BuildContext {
  VideoContext get video => VideoContext._(this);
}

class VideoContext {
  const VideoContext._(this.context);

  final BuildContext context;

  int get currentFrame {
    final frame = context
        .dependOnInheritedWidgetOfExactType<CurrentFrameProvider>()
        ?.frame;
    assert(frame != null, 'No Composition found in the widget tree');
    return frame!;
  }

  VideoConfig get config {
    final config = context
        .dependOnInheritedWidgetOfExactType<VideoConfigProvider>()
        ?.config;
    assert(config != null, 'No Composition found in the widget tree');
    return config!;
  }

  double time([int fromFrame = 0, int? toFrame]) {
    final currentFrame = this.currentFrame;
    final config = this.config;
    final effectiveToFrame = toFrame ?? config.durationInFrames - 1;
    if (currentFrame <= fromFrame) return 0;
    if (currentFrame >= effectiveToFrame) return 1;
    return (currentFrame - fromFrame) / (effectiveToFrame - fromFrame);
  }

  Animation<double> timeAnimation([int fromFrame = 0, int? toFrame]) {
    return AlwaysStoppedAnimation(time(fromFrame, toFrame));
  }
}
