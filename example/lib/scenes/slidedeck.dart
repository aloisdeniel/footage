import 'package:flutter/material.dart';
import 'package:footage/footage.dart';

class SlideDeckScene extends StatelessWidget {
  const SlideDeckScene({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const slides = [
      TitleSlide(
        title: 'Footage',
        background: Colors.red,
        foreground: Colors.white,
      ),
      DescriptionSlide(
        title: 'Versatility',
        description:
            'You can even use Footage as a slidedeck by using the Series'
            ' widget and markers.\n\nThen use arrows to navigate between slides',
      ),
      TitleSlide(
        title: 'Amazing, no?',
        background: Colors.blue,
        foreground: Colors.white,
      ),
      TitleSlide(
        title: 'Thank you!!',
        background: Colors.yellow,
        foreground: Colors.black,
      ),
    ];

    final entries = slides.asMap().entries.toList();

    return Stack(
      children: [
        Series(
          children: [
            ...entries
                .map((entry) => [
                      if (entry.key > 0)
                        SeriesSequence(
                          marker: SeriesMarker('Slide ${entry.key}'),
                          duration:
                              const Time.duration(Duration(milliseconds: 500)),
                          child: Transition(
                            slide1: entries[entry.key - 1].value,
                            slide2: entry.value,
                          ),
                        ),
                      SeriesSequence(
                        marker:
                            entry.key == 0 ? const SeriesMarker('Start') : null,
                        duration:
                            const Time.duration(Duration(milliseconds: 500)),
                        child: entry.value,
                      ),
                    ])
                .expand((element) => element),
            SeriesSequence(
              marker: const SeriesMarker('End'),
              duration: const Time.duration(Duration(hours: 24)),
              child: Freeze(
                time: const Time.relative(1),
                child: entries.last.value,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Transition extends StatelessWidget {
  const Transition({
    Key? key,
    required this.slide1,
    required this.slide2,
  }) : super(key: key);

  final Widget slide1;
  final Widget slide2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Freeze(
          time: const Time.relative(1),
          child: slide1,
        ),
        Builder(
          builder: (context) {
            return SlideTransition(
              position: Tween(
                begin: const Offset(1, 0),
                end: const Offset(0, 0),
              ).animate(
                CurvedAnimation(
                  parent: context.video.timeAnimation(),
                  curve: Curves.easeInOut,
                ),
              ),
              child: Freeze(
                time: const Time.relative(0),
                child: slide2,
              ),
            );
          },
        ),
      ],
    );
  }
}

class TitleSlide extends StatelessWidget {
  const TitleSlide({
    Key? key,
    required this.title,
    this.background = Colors.white,
    this.foreground = Colors.black,
  }) : super(key: key);

  final String title;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final time = context.video.time();
    return Container(
      color: background,
      child: Opacity(
        opacity: time,
        child: Transform.translate(
          offset: Offset(0, 100 * (1 - Curves.easeOut.transform(time))),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 200,
                fontWeight: FontWeight.w900,
                fontFamily: 'Roboto',
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DescriptionSlide extends StatelessWidget {
  const DescriptionSlide({
    Key? key,
    required this.title,
    required this.description,
    this.background = Colors.white,
    this.foreground = Colors.black,
  }) : super(key: key);

  final String title;
  final String description;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Sequence(
              from: const Time.relative(0),
              duration: const Time.relative(0.5),
              freezeAfter: true,
              child: Builder(builder: (context) {
                final time = context.video.time();
                return Opacity(
                  opacity: time,
                  child: Transform.translate(
                    offset:
                        Offset(0, 100 * (1 - Curves.easeOut.transform(time))),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Roboto',
                        color: foreground,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            Sequence(
              from: const Time.relative(0.5),
              duration: const Time.relative(0.5),
              child: Builder(builder: (context) {
                final time = context.video.time();
                return Opacity(
                  opacity: time,
                  child: Transform.translate(
                    offset:
                        Offset(0, 100 * (1 - Curves.easeOut.transform(time))),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 52,
                        fontFamily: 'Roboto',
                        color: foreground,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
