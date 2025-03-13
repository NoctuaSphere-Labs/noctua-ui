import 'package:flutter/material.dart';

class NeonIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color hoverColor;
  final double size;
  final String? tooltip;

  const NeonIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.hoverColor,
    this.size = 200,
    this.tooltip,
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
    final hoverColor = widget.hoverColor;
    final pressedColor = hoverColor.withOpacity(0.7);
    final Color effectiveHoverColor = isPressed ? pressedColor : hoverColor;
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
    final iconWidget = GestureDetector(
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
    final tooltipWidget = Tooltip(
      message: widget.tooltip ?? '',
      waitDuration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      preferBelow: false,
      showDuration: const Duration(seconds: 2),
      child: iconWidget,
    );
    return widget.tooltip != null ? tooltipWidget : iconWidget;
  }
}
