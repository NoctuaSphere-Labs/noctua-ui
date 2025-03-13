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
  bool isPressed = false;

  void onMouseRegionChanged(event) {
    setState(() {
      isHovering = !isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(25);
    final Color effectiveHoverColor = isPressed 
        ? widget.hoverColor.withOpacity(0.7) 
        : widget.hoverColor;
        
    final hoveringDecoration = BoxDecoration(
      color: Colors.black45,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: effectiveHoverColor,
          blurRadius: isPressed ? 40 : 60, // smaller blur when pressed
          spreadRadius: isPressed ? 5 : 10, // smaller spread when pressed
        ),
      ],
      border: Border.all(
        color: widget.color,
        width: 4,
      ),
    );
    final notHoveringDecoration = BoxDecoration(
      borderRadius: borderRadius,
      border: Border.all(
        color: widget.color,
      ),
    );
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: MouseRegion(
        onEnter: onMouseRegionChanged,
        onExit: onMouseRegionChanged,
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          width: widget.size * 1.50,
          transformAlignment: Alignment.center,
          clipBehavior: Clip.none,
          height: widget.size * 1.50,
          decoration: isHovering ? hoveringDecoration : notHoveringDecoration,
          duration: const Duration(microseconds: 250),
          curve: Curves.fastOutSlowIn,
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
