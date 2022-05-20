import 'dart:math';

import 'package:flutter/foundation.dart';

import 'config.dart';
import 'markers.dart';

class FootageController extends ChangeNotifier {
  int _frame = 0;
  int get frame => _frame;

  @protected
  set frame(int frame) {
    if (_frame != frame) {
      _frame = frame;
      notifyListeners();
    }
  }

  VideoConfig? _config;
  VideoConfig? get config => _config;

  set config(VideoConfig? config) {
    final oldConfig = _config;
    if (oldConfig != null && config != null) {
      final newConfig = VideoConfig(
        durationInFrames: max(
          oldConfig.durationInFrames,
          config.durationInFrames,
        ),
        fps: max(
          oldConfig.fps,
          config.fps,
        ),
        width: max(
          oldConfig.width,
          config.width,
        ),
        height: max(
          oldConfig.height,
          config.height,
        ),
      );

      if (newConfig != oldConfig) {
        _config = newConfig;
        notifyListeners();
      }
    } else if (oldConfig != config) {
      _config = config;
      notifyListeners();
    }
  }

  final List<Marker> _markers = <Marker>[];
  List<Marker> get markers => _markers;

  void addMarkers(List<Marker> markers) {
    _markers.addAll(markers);
    notifyListeners();
  }

  void removeMarkers(List<Marker> markers) {
    bool deleted = false;
    for (var marker in markers) {
      deleted = _markers.remove(marker) || deleted;
    }
    if (deleted) notifyListeners();
  }
}

enum FrameStatus {
  delayed,
  ready,
  rendered,
}
