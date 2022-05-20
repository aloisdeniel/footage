import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:footage/footage.dart';
import 'package:footage/src/preview/controller.dart';

class TimelinePreviewItemRange extends Equatable {
  const TimelinePreviewItemRange({
    required this.from,
    required this.durationInFrames,
  });
  final int from;
  final int durationInFrames;

  @override
  List<Object?> get props => [from, durationInFrames];
}

class TimelinePreviewItem extends Equatable {
  const TimelinePreviewItem({
    required this.name,
    required this.time,
    required this.color,
    required this.icon,
    this.children = const <TimelinePreviewItem>[],
  });

  static List<TimelinePreviewItem> fromTree(
    int from,
    int durationInFrames,
    int fps,
    Element element,
    Color? color,
    double alpha,
  ) {
    final result = <TimelinePreviewItem>[];

    void defaultVisit() {
      element.visitChildren((child) {
        result
            .addAll(fromTree(from, durationInFrames, fps, child, color, alpha));
      });
    }

    if (element is StatelessElement) {
      final widget = element.widget;
      if (widget is Sequence) {
        final childFrom = from + widget.from.asFrames(durationInFrames, fps);
        final childDuration =
            widget.duration?.asFrames(durationInFrames, fps) ??
                (durationInFrames - childFrom);
        final childChildren = <TimelinePreviewItem>[];
        element.visitChildren(
          (child) {
            childChildren.addAll(fromTree(
              childFrom,
              childDuration,
              fps,
              child,
              color,
              alpha * 0.7,
            ));
          },
        );
        result.add(
          TimelinePreviewItem(
            name: widget.name ?? 'Sequence',
            color: (color ?? Colors.blue).withOpacity(alpha),
            time: [
              TimelinePreviewItemRange(
                durationInFrames: childDuration,
                from: childFrom,
              )
            ],
            icon: Icons.arrow_circle_right_outlined,
            children: childChildren,
          ),
        );
      } else if (widget is Loop) {
        final childChildren = <TimelinePreviewItem>[];
        element.visitChildren((child) {
          childChildren.addAll(
            fromTree(
              from,
              durationInFrames,
              fps,
              child,
              Colors.purple.withOpacity(alpha),
              alpha * 0.7,
            ),
          );
        });
        result.add(
          TimelinePreviewItem(
            name: widget.name ?? 'Loop',
            color: (color ?? Colors.purple).withOpacity(alpha),
            time: [
              TimelinePreviewItemRange(
                durationInFrames: durationInFrames,
                from: from,
              )
            ],
            icon: Icons.loop,
            children: childChildren
                .map(
                  (child) => TimelinePreviewItem(
                    name: child.name,
                    time: [
                      for (final time in child.time) ...[
                        for (var loopStart = from;
                            loopStart < from + durationInFrames;
                            loopStart +=
                                widget.duration.asFrames(durationInFrames, fps))
                          TimelinePreviewItemRange(
                            from: loopStart + time.from,
                            durationInFrames: time.durationInFrames,
                          ),
                      ]
                    ],
                    color: child.color,
                    icon: child.icon,
                  ),
                )
                .toList(),
          ),
        );
      } else {
        defaultVisit();
      }
    } else {
      defaultVisit();
    }

    return result;
  }

  final String name;
  final Color color;
  final IconData icon;
  final List<TimelinePreviewItem> children;
  final List<TimelinePreviewItemRange> time;
  @override
  List<Object?> get props => [
        name,
        time,
        color,
        icon,
        children,
      ];
}

class TimelinePreview extends StatefulWidget {
  const TimelinePreview({
    super.key,
    required this.fps,
    required this.videoElement,
    required this.durationInFrames,
    required this.controller,
  });

  final int fps;
  final int durationInFrames;
  final Element videoElement;
  final PreviewFootageController controller;

  @override
  State<TimelinePreview> createState() => _TimelinePreviewState();
}

class _TimelinePreviewState extends State<TimelinePreview> {
  @override
  void initState() {
    super.initState();
  }

  static Iterable<TimelimeRowPreview> flattenItems(
    int level,
    TimelinePreviewItem item,
    int totalDurationInFrames,
  ) sync* {
    yield TimelimeRowPreview(
      level: level,
      item: item,
      totalDurationInFrames: totalDurationInFrames,
    );

    for (var child in item.children) {
      for (var row in flattenItems(level + 1, child, totalDurationInFrames)) {
        yield row;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = TimelinePreviewItem.fromTree(
      0,
      widget.durationInFrames,
      widget.fps,
      widget.videoElement,
      null,
      1,
    );
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: TimelimeHeaderHeaderCellPreview.width - 1,
                color: const Color(0xff171717),
              ),
              Container(
                width: 1,
                color: const Color(0xff444444),
              ),
              Expanded(
                flex: 4,
                child: Container(color: const Color(0xff111111)),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: TimelineGesture(
            onFrameChanged: (frame) {
              widget.controller.status = PlayingStatus.stopped;
              widget.controller.updateFrame(frame);
            },
            totalDurationInFrames: widget.durationInFrames,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ListView(
                children: [
                  if (widget.controller.markers.isNotEmpty)
                    TimelineMarkersRow(
                      fps: widget.controller.config?.fps ?? 30,
                      frame: widget.controller.frame,
                      totalDurationInFrames:
                          widget.controller.config?.durationInFrames ?? 0,
                      markers: widget.controller.markers,
                    ),
                  for (var child in children)
                    ...flattenItems(
                      0,
                      child,
                      widget.controller.config?.durationInFrames ?? 0,
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: TimelineTimeIndicator(
              frame: widget.controller.frame,
              durationInFrames: widget.durationInFrames,
            ),
          ),
        ),
      ],
    );
  }
}

class TimelineTimeIndicator extends StatelessWidget {
  const TimelineTimeIndicator({
    Key? key,
    required this.frame,
    required this.durationInFrames,
  }) : super(key: key);

  final int frame;
  final int durationInFrames;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: TimelimeHeaderHeaderCellPreview.width - 1,
        ),
        Expanded(
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: frame,
                child: const SizedBox(),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(width: 1, color: Colors.red),
                  Positioned(
                    top: 0,
                    left: -4,
                    right: -4,
                    height: 12,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                flex: (durationInFrames - 1) - frame,
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TimelineMarkersRow extends StatelessWidget {
  const TimelineMarkersRow({
    Key? key,
    required this.frame,
    required this.totalDurationInFrames,
    required this.fps,
    required this.markers,
  }) : super(key: key);

  final int frame;
  final List<Marker> markers;
  final int totalDurationInFrames;
  final int fps;

  @override
  Widget build(BuildContext context) {
    final orderedMarkers = [...markers].toList()
      ..sort((x, y) => x.at
          .asFrames(totalDurationInFrames, fps)
          .compareTo(y.at.asFrames(totalDurationInFrames, fps)));
    final previousMarker = orderedMarkers.lastWhereOrNull(
      (x) => x.at.asFrames(totalDurationInFrames, fps) <= frame,
    );
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          width: TimelimeHeaderHeaderCellPreview.width,
          child: Text(
            previousMarker?.name ?? '',
            style: TextStyle(
              color: previousMarker?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 18,
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    for (var marker in markers)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: -1 +
                            constraints.maxWidth *
                                (marker.at
                                        .asFrames(totalDurationInFrames, fps) /
                                    (totalDurationInFrames - 1)),
                        width: 1,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: 0,
                              left: -4,
                              right: -4,
                              bottom: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: marker.color,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TimelimeRowPreview extends StatelessWidget {
  const TimelimeRowPreview({
    super.key,
    required this.level,
    required this.item,
    required this.totalDurationInFrames,
  });
  final int level;
  final TimelinePreviewItem item;
  final int totalDurationInFrames;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimelimeHeaderHeaderCellPreview(
            item: item,
            level: level,
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: TimelimeHeaderTimeCellPreview(
                item: item,
                totalDurationInFrames: totalDurationInFrames,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelimeHeaderHeaderCellPreview extends StatelessWidget {
  const TimelimeHeaderHeaderCellPreview({
    super.key,
    required this.level,
    required this.item,
  });
  final int level;
  final TimelinePreviewItem item;

  static double width = 200;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(4) + EdgeInsets.only(left: level * 10),
      alignment: Alignment.centerLeft,
      child: Text(
        item.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}

class TimelineGesture extends StatelessWidget {
  const TimelineGesture({
    Key? key,
    required this.child,
    required this.onFrameChanged,
    required this.totalDurationInFrames,
  }) : super(key: key);
  final ValueChanged<int> onFrameChanged;
  final int totalDurationInFrames;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth =
            constraints.maxWidth - TimelimeHeaderHeaderCellPreview.width;
        int getFrameForX(double dx) {
          return (((dx - TimelimeHeaderHeaderCellPreview.width) / totalWidth)
                      .clamp(0, 1) *
                  (totalDurationInFrames - 1))
              .round();
        }

        return GestureDetector(
          onPanUpdate: (details) =>
              onFrameChanged(getFrameForX(details.localPosition.dx)),
          onPanStart: (details) =>
              onFrameChanged(getFrameForX(details.localPosition.dx)),
          behavior: HitTestBehavior.opaque,
          child: child,
        );
      },
    );
  }
}

class TimelimeHeaderTimeCellPreview extends StatelessWidget {
  const TimelimeHeaderTimeCellPreview({
    super.key,
    required this.item,
    required this.totalDurationInFrames,
  });
  final int totalDurationInFrames;
  final TimelinePreviewItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            for (var time in item.time)
              Positioned(
                top: 0,
                bottom: 0,
                left: constraints.maxWidth *
                    (time.from / (totalDurationInFrames - 1)),
                width: constraints.maxWidth *
                    (time.durationInFrames / (totalDurationInFrames - 1)),
                child: Container(
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 6,
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
