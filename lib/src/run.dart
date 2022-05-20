import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:footage/src/renderer/renderer.dart';

import 'preview/run.dart';

void runVideo(
  Widget app, {
  bool timeline = true,
  bool panel = true,
}) {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    renderVideo(app);
  } else {
    previewVideo(
      app,
      timeline: timeline,
      panel: panel,
    );
  }
}
