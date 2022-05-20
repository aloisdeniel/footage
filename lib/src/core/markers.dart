import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:footage/footage.dart';
import 'package:footage/src/core/providers.dart';

/// Markers allows to indicate important key frames in order to navigate
/// more easily when in preview mode.
class Markers extends StatefulWidget {
  const Markers({
    super.key,
    required this.markers,
    required this.child,
  });

  final List<Marker> markers;
  final Widget child;

  @override
  State<Markers> createState() => _MarkersState();
}

class _MarkersState extends State<Markers> {
  FootageController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller == null) {
      final controller = FootageControllerProvider.of(context);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller.addMarkers(widget.markers);
      });
      this.controller = controller;
    }
  }

  @override
  void didUpdateWidget(covariant Markers oldWidget) {
    if (!const ListEquality().equals(oldWidget.markers, widget.markers)) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller?.removeMarkers(oldWidget.markers);
        controller?.addMarkers(widget.markers);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller?.removeMarkers(widget.markers);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class Marker extends Equatable {
  const Marker(
    this.at,
    this.name, {
    this.color = Colors.orange,
  });

  final String name;
  final Time at;
  final Color color;

  @override
  List<Object?> get props => [name, at, color];
}
