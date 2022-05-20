import 'package:flutter/material.dart';

class PreviewToolBase extends StatelessWidget {
  const PreviewToolBase({
    super.key,
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mediaQuery =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return MediaQuery(
      data: mediaQuery,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: mediaQuery.size.width,
            height: height,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  maintainState: true,
                  opaque: true,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
