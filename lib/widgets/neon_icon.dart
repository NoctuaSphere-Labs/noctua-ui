import 'package:flutter/material.dart';

class NeonIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color hoverColor;
  final double size;

  const NeonIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.hoverColor,
    this.size = 200,
  });

  @override
  State<NeonIcon> createState() => _NeonIconState();
}

class _NeonIconState extends State<NeonIcon> {
  bool isHovering = false;

  void onMouseRegionChanged(event) {
    setState(() {
      isHovering = !isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: onMouseRegionChanged,
      onExit: onMouseRegionChanged,
      child: AnimatedContainer(
          padding: EdgeInsets.zero,
          width: isHovering ? widget.size * 1.40 : widget.size * 1.25,
          transform: Matrix4.rotationZ(0),
          transformAlignment: Alignment.center,
          clipBehavior: isHovering ? Clip.none : Clip.none,
          height: isHovering ? widget.size * 1.40 : widget.size * 1.25,
          decoration: isHovering
              ? BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: widget.hoverColor,
                      blurRadius: 60, // soften the shadow
                      spreadRadius: 10, //extend the shadow
                    ),
                  ],
                  border: Border.all(
                    color: widget.color,
                    width: 4,
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: widget.color,
                  ),
                ),
          duration: const Duration(microseconds: 250),
          curve: Curves.fastOutSlowIn,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Icon(
              widget.icon,
              color: widget.color,
              size: widget.size,
            ),
          ),
        ),
    );
  }
}
