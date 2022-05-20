import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:footage/footage.dart';

class BasicScene extends StatelessWidget {
  const BasicScene({Key? key}) : super(key: key);

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
