import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final List<Widget> children;
  final double iconWidth;
  final double iconLength;

  const NavBar({
    super.key,
    required this.children,
    required this.iconWidth,
    required this.iconLength,
  });

  @override
  Widget build(BuildContext context) {
    final background = BlurryContainer(
      blur: 8,
      height: 150,
      elevation: 6,
      padding: const EdgeInsets.all(32),
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(15),
      child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          // This prevents the shadow from being clipped
          clipBehavior: Clip.none,
          children: children,
        ),
    );
    return background;
  }
}
