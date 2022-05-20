import 'package:equatable/equatable.dart';

class VideoConfig extends Equatable {
  const VideoConfig({
    required this.durationInFrames,
    required this.fps,
    required this.width,
    required this.height,
  });
  final int durationInFrames;
  final int fps;
  final int width;
  final int height;

  int framesForDuration(Duration duration) {
    return duration.inSeconds * fps;
  }

  Duration durationForFrames(int durationInFrames) {
    return Duration(seconds: (durationInFrames / fps).floor());
  }

  @override
  List<Object?> get props => [
        durationInFrames,
        fps,
        width,
        height,
      ];
}
