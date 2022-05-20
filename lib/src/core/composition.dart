import 'package:flutter/widgets.dart';
import 'package:footage/src/core/time.dart';

import 'config.dart';
import 'providers.dart';

class Composition extends StatefulWidget {
  Composition({
    super.key,
    required this.child,
    required this.duration,
    this.fps = 30,
    this.width = 1920,
    this.height = 1080,
  }) : assert(
          duration.map(
            (frames) => true,
            (percent) => false,
            (duration) => true,
          ),
          'The duration can\'t be relative',
        );

  final Widget child;
  final Time duration;
  final int fps;
  final int width;
  final int height;

  VideoConfig get config => VideoConfig(
        fps: fps,
        durationInFrames: duration.asFrames(0, fps),
        width: width,
        height: height,
      );

  @override
  State<Composition> createState() => _CompositionState();
}

class _CompositionState extends State<Composition> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = FootageControllerProvider.of(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.config = widget.config;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VideoConfigProvider(
      config: widget.config,
      child: widget.child,
    );
  }
}
