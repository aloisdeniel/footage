import 'package:flutter/material.dart';
import 'package:footage/src/preview/controller.dart';

import 'base.dart';
import 'timeline.dart';
import 'toolbar.dart';

class PreviewToolPanel extends StatefulWidget {
  const PreviewToolPanel({
    super.key,
    required this.timeline,
    required this.videoKey,
    required this.controller,
  });

  final bool timeline;
  final GlobalKey videoKey;
  final PreviewFootageController controller;

  @override
  State<PreviewToolPanel> createState() => _PreviewToolPanelState();
}

class _PreviewToolPanelState extends State<PreviewToolPanel> {
  late final ValueNotifier<bool> isTimelineVisible =
      ValueNotifier(widget.timeline);

  @override
  void didUpdateWidget(covariant PreviewToolPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeline != oldWidget.timeline) {
      if (!widget.timeline) {
        isTimelineVisible.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff111111),
      child: PreviewToolBase(
        height: isTimelineVisible.value ? 300 + 40 : 40,
        child: AnimatedBuilder(
          animation: isTimelineVisible,
          builder: (context, child) => AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              final videoContext = widget.videoKey.currentContext;
              final config = widget.controller.config;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PreviewToolbar(
                    canUpdateTimelineVisibility: widget.timeline,
                    controller: widget.controller,
                    isTimelineVisible: isTimelineVisible.value,
                    onTimelineVisibleChanged: () => setState(() =>
                        isTimelineVisible.value = !isTimelineVisible.value),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: widget.timeline &&
                              videoContext is Element &&
                              config != null &&
                              isTimelineVisible.value
                          ? TimelinePreview(
                              key: const Key('Timeline'),
                              videoElement: videoContext,
                              durationInFrames: config.durationInFrames,
                              fps: config.fps,
                              controller: widget.controller,
                            )
                          : const SizedBox(key: Key('Empty')),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
