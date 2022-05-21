/// A time representation that can be absolute or relative to another element.
abstract class Time {
  /// A time duration for a given [frames] count.
  const factory Time.frames(int frames) = _FrameOffset;

  /// A time duration in [percent] (`1.0` is equivalent to parent's full
  /// duration), relative to the parent duration.
  const factory Time.relative(double percent) = _RelativeOffset;

  /// A time duration in real time.
  const factory Time.duration(Duration duration) = _DurationOffset;

  const Time._();

  /// Map this value to a value of type [T], regarding the current type of
  /// time : [frames], [relative] or [duration].
  T map<T>(
    T Function(int frames) frames,
    T Function(double percent) relative,
    T Function(Duration duration) duration,
  ) {
    final value = this;
    if (value is _FrameOffset) {
      return frames(value.frames);
    }
    if (value is _RelativeOffset) {
      return relative(value.percent);
    }
    if (value is _DurationOffset) {
      return duration(value.duration);
    }

    throw Exception();
  }

  /// Converts this time value to a number of frames.
  ///
  /// The [parentDurationInFrames] and [fps] are required in case this time
  /// is relative.
  int asFrames(int parentDurationInFrames, int fps) {
    return map(
      (frames) => frames,
      (percent) => (percent * parentDurationInFrames).round(),
      (duration) => ((duration.inMilliseconds / 1000) * fps).round(),
    );
  }
}

class _FrameOffset extends Time {
  const _FrameOffset(this.frames) : super._();
  final int frames;
}

class _RelativeOffset extends Time {
  const _RelativeOffset(this.percent) : super._();
  final double percent;
}

class _DurationOffset extends Time {
  const _DurationOffset(this.duration) : super._();
  final Duration duration;
}
