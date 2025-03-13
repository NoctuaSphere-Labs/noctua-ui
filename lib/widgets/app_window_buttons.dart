import 'package:flutter/material.dart';

class AppWindowButtons extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final double buttonSize;

  const AppWindowButtons({
    super.key,
    this.onClose,
    this.onMinimize,
    this.onMaximize,
    this.buttonSize = 12,
  });

  @override
  State<AppWindowButtons> createState() => _AppWindowButtonsState();
}

class _AppWindowButtonsState extends State<AppWindowButtons> {
  // Store the hover state for each button
  bool _isRedHovered = false;
  bool _isYellowHovered = false;
  bool _isGreenHovered = false;
  static const double _buttonSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isRedHovered = true),
          onExit: (_) => setState(() => _isRedHovered = false),
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: widget.buttonSize,
              height: widget.buttonSize,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(widget.buttonSize / 2),
                border: Border.all(
                  color: Colors.red.shade800,
                  width: 0.5,
                ),
              ),
              child: _isRedHovered
                  ? const Icon(
                      Icons.close,
                      size: 8,
                      color: Colors.black54,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: _buttonSpacing),
        MouseRegion(
          onEnter: (_) => setState(() => _isYellowHovered = true),
          onExit: (_) => setState(() => _isYellowHovered = false),
          child: GestureDetector(
            onTap: widget.onMinimize,
            child: Container(
              width: widget.buttonSize,
              height: widget.buttonSize,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(widget.buttonSize / 2),
                border: Border.all(
                  color: Colors.yellow.shade800,
                  width: 0.5,
                ),
              ),
              child: _isYellowHovered
                  ? const Icon(
                      Icons.horizontal_rule,
                      size: 12,
                      color: Colors.black54,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: _buttonSpacing),
        MouseRegion(
          onEnter: (_) => setState(() => _isGreenHovered = true),
          onExit: (_) => setState(() => _isGreenHovered = false),
          child: GestureDetector(
            onTap: widget.onMaximize,
            child: Container(
              width: widget.buttonSize,
              height: widget.buttonSize,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(widget.buttonSize / 2),
                border: Border.all(
                  color: Colors.green.shade800,
                  width: 0.5,
                ),
              ),
              child: _isGreenHovered
                  ? const Icon(
                      Icons.unfold_more,
                      size: 8,
                      color: Colors.black54,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
