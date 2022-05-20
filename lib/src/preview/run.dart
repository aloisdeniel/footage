import 'package:flutter/material.dart';

import 'preview.dart';

void previewVideo(
  Widget app, {
  bool timeline = true,
  bool panel = true,
}) {
  return runApp(
    FootagePreview(
      timeline: timeline,
      panel: panel,
      child: app,
    ),
  );
}
