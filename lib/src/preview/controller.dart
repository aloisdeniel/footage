import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:footage/footage.dart';

enum PlayingStatus {
  backward,
  stopped,
  forward,
}

class PreviewFootageController extends FootageController {
  PreviewFootageController({
    required TickerProvider vsync,
  }) {
    _ticker = vsync.createTicker(_onTick);
    _ticker.start();
  }

  bool get isPlaying => status != PlayingStatus.stopped;

  PlayingStatus _status = PlayingStatus.stopped;
  PlayingStatus get status => _status;

  set status(PlayingStatus value) {
    if (_status != value) {
      _status = value;
      notifyListeners();
    }
  }

  late final Ticker _ticker;
  Duration _lastEllapsed = Duration.zero;
  int? _stopAtFrame;

  void _onTick(Duration ellapsed) {
    final config = this.config;
    if (status != PlayingStatus.stopped) {
      if (config != null) {
        final relativeEllapsed = ellapsed - _lastEllapsed;
        final ellapsedFrames =
            ((relativeEllapsed.inMilliseconds / 1000.0) * config.fps).round();
        if (ellapsedFrames > 0) {
          frame = (frame +
                  ellapsedFrames *
                      (status == PlayingStatus.backward ? -1 : 1)) %
              config.durationInFrames;
          _lastEllapsed = ellapsed;
        }
      }
      if (frame == _stopAtFrame) {
        status = PlayingStatus.stopped;
        _stopAtFrame = null;
      }
    } else {
      _lastEllapsed = ellapsed;
    }
  }

  void updateFrame(int frame) =>
      this.frame = max(0, frame % (config?.durationInFrames ?? 1));

  void togglePlay() {
    if (status == PlayingStatus.stopped) {
      status = PlayingStatus.forward;
    } else {
      status = PlayingStatus.stopped;
    }
  }

  void previousFrame() {
    status = PlayingStatus.stopped;
    updateFrame(frame - 1);
  }

  void nextFrame() {
    status = PlayingStatus.stopped;
    updateFrame(frame + 1);
  }

  void goToNextMarker() {
    final config = this.config;
    if (config != null) {
      final orderedMarkers = markers.toList()
        ..sort((x, y) => x.at
            .asFrames(config.durationInFrames, config.fps)
            .compareTo(y.at.asFrames(config.durationInFrames, config.fps)));
      _stopAtFrame = orderedMarkers
          .map((x) => x.at.asFrames(config.durationInFrames, config.fps))
          .firstWhere(
            (x) => x > frame,
            orElse: () => (config.durationInFrames - 1),
          );
      status = PlayingStatus.forward;
    }
  }

  void goToPreviousMarker() {
    final config = this.config;
    if (config != null) {
      final orderedMarkers = markers.toList()
        ..sort((x, y) => x.at
            .asFrames(config.durationInFrames, config.fps)
            .compareTo(y.at.asFrames(config.durationInFrames, config.fps)));
      _stopAtFrame = orderedMarkers
          .map((x) => x.at.asFrames(config.durationInFrames, config.fps))
          .lastWhere(
            (x) => x < frame,
            orElse: () => 0,
          );
      status = PlayingStatus.backward;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _ticker.dispose();
  }
}
