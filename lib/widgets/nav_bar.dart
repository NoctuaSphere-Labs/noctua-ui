import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class NavBar extends StatefulWidget {
  final Widget child;

  const NavBar({super.key, required this.child});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BlurryContainer(
          blur: 8,
          height: 140,
          width: double.infinity,
          elevation: 6,
          padding: const EdgeInsets.all(32),
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          child: const SizedBox.shrink(),
        ),
        Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              final offset =
                  _scrollController.offset + pointerSignal.scrollDelta.dy;
              _scrollController.jumpTo(
                offset.clamp(
                  0.0,
                  _scrollController.position.maxScrollExtent,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
