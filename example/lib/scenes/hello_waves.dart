import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:footage/footage.dart';

class HelloWavesScene extends StatelessWidget {
  const HelloWavesScene({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Markers(
      markers: const [
        Marker(Time.frames(0), 'Intro'),
        Marker(Time.frames(10), 'Title'),
        Marker(Time.frames(60), 'Outro', color: Colors.pink),
      ],
      child: Stack(
        children: [
          const Loop(
            duration: Time.frames(20),
            child: Sequence(
              name: 'Repeated circles',
              from: Time.frames(0),
              duration: Time.frames(10),
              child: GrowingCircle(
                maxScale: 3,
              ),
            ),
          ),
          Sequence(
            name: 'Circles',
            from: const Time.frames(20),
            duration: const Time.frames(40),
            child: Stack(
              children: const [
                Sequence(
                  name: 'Circle 1',
                  from: Time.frames(0),
                  duration: Time.frames(20),
                  child: GrowingCircle(
                    maxScale: 5,
                  ),
                ),
                Sequence(
                  name: 'Circle 2',
                  from: Time.frames(10),
                  duration: Time.frames(30),
                  child: GrowingCircle(
                    maxScale: 10,
                  ),
                ),
                Sequence(
                  name: 'Circle 3',
                  from: Time.frames(20),
                  duration: Time.frames(20),
                  child: GrowingCircle(
                    maxScale: 30,
                  ),
                ),
              ],
            ),
          ),
          const Sequence(
            name: 'Hello',
            from: Time.frames(10),
            duration: Time.frames(30),
            child: RotatingTitle(
              fontSize: 42,
              title: 'Hello',
              startAngle: 0,
              endAngle: math.pi,
            ),
          ),
          const Sequence(
            name: 'World',
            from: Time.frames(25),
            duration: Time.frames(30),
            child: RotatingTitle(
              fontSize: 82,
              title: 'World',
              startAngle: math.pi,
              endAngle: math.pi * 2,
            ),
          ),
        ],
      ),
    );
  }
}

class GrowingCircle extends StatelessWidget {
  const GrowingCircle({
    Key? key,
    this.maxScale = 10,
    this.child = const SizedBox(),
  }) : super(key: key);

  final double maxScale;
  final Widget child;

  static final colors = TweenSequence([
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.pink.withAlpha(0), end: Colors.red),
      weight: 2,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.red, end: Colors.blue.withAlpha(0)),
      weight: 2,
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    final time = context.video.time();
    return Center(
      child: Transform.scale(
        scale: Curves.easeOutQuart.transform(time) * maxScale,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colors.transform(Curves.easeOutQuart.transform(time))!,
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }
}

class RotatingTitle extends StatelessWidget {
  const RotatingTitle({
    Key? key,
    required this.startAngle,
    required this.endAngle,
    required this.fontSize,
    required this.title,
  }) : super(key: key);

  final double startAngle;
  final double endAngle;
  final String title;
  final double fontSize;

  static final opacity = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
  ]);

  @override
  Widget build(BuildContext context) {
    final time = context.video.time();

    return Opacity(
      opacity: opacity.transform(Curves.easeInOut.transform(time)),
      child: Center(
        child: Transform.rotate(
          angle: startAngle +
              (endAngle - startAngle) * Curves.easeInOut.transform(time),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
