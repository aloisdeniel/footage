import 'package:example/scenes/hello_waves.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:footage/footage.dart';

void main() {
  runVideo(
    const Video(),
    panel: false,
  );
}

class Video extends StatelessWidget {
  const Video({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Composition(
      fps: 30,
      duration: const Time.frames(90),
      width: 1920,
      height: 1080,
      child: const HelloWavesScene(),
    );
  }
}
