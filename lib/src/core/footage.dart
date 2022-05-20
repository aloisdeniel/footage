import 'package:flutter/widgets.dart';
import 'package:footage/footage.dart';

import 'providers.dart';

class Footage extends StatelessWidget {
  const Footage({
    super.key,
    required this.controller,
    required this.child,
    this.textDirection = TextDirection.ltr,
  });

  final TextDirection textDirection;
  final FootageController controller;
  final Widget child;

  VideoContext of(BuildContext context) => context.video;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: FootageControllerProvider(
        controller: controller,
        child: AnimatedBuilder(
          animation: controller,
          child: child,
          builder: (context, child) {
            return CurrentFrameProvider(
              frame: controller.frame,
              child: child ?? const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}
