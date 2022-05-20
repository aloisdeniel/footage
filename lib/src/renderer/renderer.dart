// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:footage/src/core/footage.dart';
import 'package:path/path.dart';

import 'assets.dart';
import 'controller.dart';

Directory _defaultDirectory() {
  final directory = Directory(
    join(
      dirname(Platform.script.toString().replaceAll('file:///', '/')),
      'build',
      'video',
    ),
  );

  return directory;
}

void renderVideo(
  Widget app, {
  Directory? directory,
}) {
  final effectiveDirectory = directory ?? _defaultDirectory();
  testWidgets(
    'Rendering video',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.runAsync<String?>(() async {
        await loadFonts();
        return null;
      });
      final controller = RenderFootageController();
      final footage = Footage(
        controller: controller,
        child: app,
      );

      print('Loading composition...');
      while (controller.config == null) {
        await tester.pumpWidget(footage);
      }

      final config = controller.config!;
      binding.window.devicePixelRatioTestValue = 1.0;
      binding.window.physicalSizeTestValue = Size(
        config.width.toDouble(),
        config.height.toDouble(),
      );

      print('Creating directory $effectiveDirectory...');
      effectiveDirectory.createSync(recursive: true);

      print('Creating config...');
      final configFile = File(join(effectiveDirectory.path, 'config.json'));
      final configJson = jsonEncode({
        'width': config.width,
        'height': config.height,
        'fps': config.fps,
        'durationInFrames': config.durationInFrames,
      });

      print('Config : $configJson');
      configFile.writeAsStringSync(configJson);

      for (var frame = 0; frame < config.durationInFrames; frame++) {
        print('Frame $frame/${config.durationInFrames}');
        controller.updateFrame(frame);
        await tester.pumpWidget(footage);
        final imageFuture = captureImage(tester.allElements.first);

        await binding.runAsync<String?>(() async {
          final image = await imageFuture;

          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          if (bytes == null) {
            return 'could not encode screenshot.';
          }
          final frameFile =
              File(join(effectiveDirectory.path, 'frames', '$frame.png'));
          print('Saving frame to $frameFile');
          try {
            await frameFile.parent.create(recursive: true);
            await frameFile.writeAsBytes(bytes.buffer.asInt8List(),
                flush: true);
          } catch (e) {
            print('Failed: $e');
          }
          return null;
        });
      }
    },
  );
}

/// Render the closest [RepaintBoundary] of the [element] into an image.
///
/// See also:
///
///  * [OffsetLayer.toImage] which is the actual method being called.
Future<ui.Image> captureImage(Element element) {
  assert(element.renderObject != null);
  RenderObject renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent! as RenderObject;
  }
  assert(!renderObject.debugNeedsPaint);
  final layer = renderObject.debugLayer! as OffsetLayer;
  return layer.toImage(renderObject.paintBounds);
}
