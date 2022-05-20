import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:footage/src/preview/actions.dart';
import 'package:footage/src/preview/controller.dart';

class PreviewToolbar extends StatelessWidget {
  const PreviewToolbar({
    Key? key,
    required this.controller,
    required this.isTimelineVisible,
    required this.onTimelineVisibleChanged,
    required this.canUpdateTimelineVisibility,
  }) : super(key: key);

  final PreviewFootageController controller;
  final bool canUpdateTimelineVisibility;
  final bool isTimelineVisible;
  final VoidCallback onTimelineVisibleChanged;

  @override
  Widget build(BuildContext context) {
    final frame = controller.frame;
    final config = controller.config;
    if (config == null) {
      return const SizedBox();
    }
    final orderedMarkers = [...controller.markers].toList()
      ..sort((x, y) => x.at
          .asFrames(config.durationInFrames, config.fps)
          .compareTo(y.at.asFrames(config.durationInFrames, config.fps)));
    final previousMarker = orderedMarkers.lastWhereOrNull(
      (x) => x.at.asFrames(config.durationInFrames, config.fps) <= frame,
    );
    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: Stack(
        children: [
          Container(
            height: 40,
            color: const Color(0xff101010),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fast_rewind_sharp),
                      onPressed: () =>
                          GoToPreviousMarkerActionIntent.invoke(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () =>
                          PreviousFrameActionIntent.invoke(context),
                    ),
                    IconButton(
                      icon: Icon(controller.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: () => PreviewActionIntent.invoke(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => NextFrameActionIntent.invoke(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fast_forward_sharp),
                      onPressed: () =>
                          GoToNextMarkerActionIntent.invoke(context),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (previousMarker != null) ...[
                                Text(
                                  previousMarker.name,
                                  style: TextStyle(
                                    color: previousMarker.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                '${_formatDuration(config.durationForFrames(frame))}/'
                                '${_formatDuration(config.durationForFrames(config.durationInFrames))}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$frame/${config.durationInFrames - 1}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canUpdateTimelineVisibility)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        transformAlignment: Alignment.center,
                        transform: Matrix4.rotationZ(
                            isTimelineVisible ? -pi / 2 : pi / 2),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => onTimelineVisibleChanged(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: FractionallySizedBox(
              alignment: Alignment.topLeft,
              widthFactor: controller.frame / (config.durationInFrames - 1),
              child: Container(
                color: const Color(0xffaaaaaa),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  return '${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.toString().padLeft(2, '0')}';
}
