import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';

/// This loads fonts for the renderer.
Future<void> loadFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadFrameworkFont('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Bold.ttf',
    'Roboto-Black.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Light.ttf',
    'Roboto-Thin.ttf',
  ]);

  await loadFrameworkFont('MaterialIcons', [
    'MaterialIcons-Regular.otf',
  ]);
}

Future<void> loadFrameworkFont(String name, List<String> files) {
  const fs = LocalFileSystem();
  const platform = LocalPlatform();
  final flutterRoot = fs.directory(platform.environment['FLUTTER_ROOT']);

  final loader = FontLoader(name);
  for (var file in files) {
    final path = fs.path.join(
      'bin',
      'cache',
      'artifacts',
      'material_fonts',
      file,
    );
    final font = flutterRoot.childFile(path);

    final bytes = Future<ByteData>.value(
      font.readAsBytesSync().buffer.asByteData(),
    );

    loader.addFont(bytes);
  }

  return loader.load();
}
