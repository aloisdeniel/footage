import 'package:flutter/material.dart';
import 'package:footage/src/core/controller.dart';

import 'config.dart';

class FootageControllerProvider extends InheritedWidget {
  const FootageControllerProvider({
    super.key,
    required super.child,
    required this.controller,
  });

  final FootageController controller;

  static FootageController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FootageControllerProvider>()!
        .controller;
  }

  @override
  bool updateShouldNotify(covariant FootageControllerProvider oldWidget) {
    return oldWidget.controller != controller;
  }
}

class CurrentFrameProvider extends InheritedWidget {
  const CurrentFrameProvider({
    required super.child,
    required this.frame,
    Key? key,
  }) : super(key: key);

  final int frame;

  @override
  bool updateShouldNotify(covariant CurrentFrameProvider oldWidget) {
    return oldWidget.frame != frame;
  }
}

class VideoConfigProvider extends InheritedWidget {
  const VideoConfigProvider({
    required super.child,
    required this.config,
    Key? key,
  }) : super(key: key);

  final VideoConfig config;

  @override
  bool updateShouldNotify(covariant VideoConfigProvider oldWidget) {
    return oldWidget.config != config;
  }
}
