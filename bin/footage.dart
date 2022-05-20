// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';

void main(List<String> args) async {
  final runner = CommandRunner(
    "footage",
    "Write your videos with Flutter",
  )
    ..addCommand(RenderCommand())
    ..addCommand(PreviewCommand())
    ..addCommand(CreateCommand());

  await runner.run(args);
}

class RenderCommand extends Command {
  @override
  String get name => "render";

  @override
  String get description => "Renders all frames from the video.";

  RenderCommand() {
    argParser.addOption('format', abbr: 'f', defaultsTo: 'png');
  }

  Future<void> generateFrames() async {
    final process = await Process.start('flutter', [
      'test',
      'lib/main.dart',
    ]);

    process.stdout.transform(utf8.decoder).forEach(print);
    process.stderr.transform(utf8.decoder).forEach(print);

    if (await process.exitCode != 0) throw Exception();
  }

  Future<void> generateWebm() async {
    final configFile = File('build/video/config.json');
    final config = jsonDecode(await configFile.readAsString());

    final process = await Process.start('ffmpeg', [
      '-i',
      'build/video/frames/%d.png',
      '-pix_fmt',
      'yuva420p',
      '-filter:v',
      'fps=${config['fps']}',
      'build/video/out.webm',
    ]);

    process.stdout.transform(utf8.decoder).forEach(print);
    process.stderr.transform(utf8.decoder).forEach(print);

    if (await process.exitCode != 0) throw Exception();
  }

  @override
  Future<void> run() async {
    final dir = Directory('build/video');
    if (dir.existsSync()) await dir.delete(recursive: true);
    await generateFrames();
    final format = argResults?['format'];
    if (format == 'webm') {
      await generateWebm();
    }
  }
}

class PreviewCommand extends Command {
  @override
  String get name => "preview";

  @override
  String get description =>
      "Start a preview of the video as a regular flutter app.";

  PreviewCommand() {
    argParser.addOption('device', abbr: 'd');
  }

  @override
  Future<void> run() async {
    final argResults = this.argResults;
    final device = argResults?['device'];
    final process = await Process.start('flutter', [
      'run',
      if (device != null) ...['-d', device],
    ]);

    process.stdout.transform(utf8.decoder).forEach(print);
    process.stderr.transform(utf8.decoder).forEach(print);

    if (await process.exitCode != 0) throw Exception();
  }
}

class CreateCommand extends Command {
  @override
  String get name => "create";

  @override
  String get description => "Creates a new video project.";

  CreateCommand();

  Future<void> createFlutterProject() async {
    final argResults = this.argResults;
    final rest = argResults?.rest ?? [];
    final process = await Process.start('flutter', [
      'create',
      if (rest.isEmpty) ...['.'],
      if (rest.isNotEmpty) ...rest,
    ]);

    process.stdout.transform(utf8.decoder).forEach(print);
    process.stderr.transform(utf8.decoder).forEach(print);

    if (await process.exitCode != 0) throw Exception();
  }

  Future<void> installFootagePackage() async {
    final process = await Process.start('flutter', [
      'pub',
      'install',
      'footage',
    ]);

    process.stdout.transform(utf8.decoder).forEach(print);
    process.stderr.transform(utf8.decoder).forEach(print);

    if (await process.exitCode != 0) throw Exception();
  }

  Future<void> replaceMainDart() async {
    final main = File('lib/main.dart');
    await main.writeAsString(initMainTemplate);
  }

  @override
  Future<void> run() async {
    await createFlutterProject();
    await installFootagePackage();
    await replaceMainDart();
  }
}

const initMainTemplate = r'''
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:footage/footage.dart';

void main() {
  runVideo(const Video());
}

class Video extends StatelessWidget {
  const Video({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Composition(
      fps: 30,
      durationInFrames: 60,
      width: 1920,
      height: 1080,
      child: Scene(),
    );
  }
}

class Scene extends StatelessWidget {
  const Scene({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.video.config;
    final time = context.video.time();
    return Center(
      child: Transform.rotate(
        angle: math.pi * 2 * Curves.easeInOut.transform(time),
        child: Text(
          'Hello world\n${config.width}x${config.height}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 82,
          ),
        ),
      ),
    );
  }
}
''';
