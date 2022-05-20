import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:footage/src/core/footage.dart';

import 'actions.dart';
import 'controller.dart';
import 'tools/tool_panel.dart';

class FootagePreview extends StatefulWidget {
  const FootagePreview({
    super.key,
    required this.timeline,
    required this.panel,
    required this.child,
  });

  final bool timeline;
  final bool panel;
  final Widget child;

  @override
  State<FootagePreview> createState() => _FootagePreviewState();
}

class _FootagePreviewState extends State<FootagePreview>
    with TickerProviderStateMixin {
  late final controller = PreviewFootageController(
    vsync: this,
  );

  final FocusNode focus = FocusNode();

  final videoKey = GlobalKey();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewActions(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xff000000),
                  Color(0xff222222),
                ], begin: Alignment.bottomLeft, end: Alignment.topRight),
              ),
              child: FittedBox(
                child: Container(
                  color: const Color(0xbb000000),
                  width: (controller.config?.width ?? 1920).toDouble(),
                  height: (controller.config?.height ?? 1080).toDouble(),
                  child: ClipRect(
                    child: Footage(
                      controller: controller,
                      child: KeyedSubtree(
                        key: videoKey,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.panel)
            PreviewToolPanel(
              videoKey: videoKey,
              controller: controller,
              timeline: widget.timeline,
            ),
        ],
      ),
    );
  }
}
