import 'package:flutter/material.dart';

class DraggableContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onClose;

  const DraggableContainer({
    super.key,
    required this.child,
    this.onClose,
  });

  @override
  State<DraggableContainer> createState() => _DraggableContainerState();
}

class _DraggableContainerState extends State<DraggableContainer> {
  bool _started = false;
  Offset? _position;
  double _width = 440;
  double _height = 240;
  bool _isResizing = false;
  ResizeDirection _resizeDirection = ResizeDirection.none;
  bool _isMinimized = false;
  bool _isMaximized = false;
  Size? _originalSize;
  Offset? _originalPosition;

  // Store the hover state for each button
  bool _isRedHovered = false;
  bool _isYellowHovered = false;
  bool _isGreenHovered = false;

  // Define constants for window control buttons
  static const double _buttonSize = 12.0;
  static const double _buttonSpacing = 8.0;
  static const double _buttonMargin = 32.0;

  // Define constants for resize handle size
  static const double _handleSize = 10;
  static const double _cornerHandleSize = 14;

  // Set cursor based on resize direction
  MouseCursor _getCursor(ResizeDirection direction) {
    switch (direction) {
      case ResizeDirection.topLeft:
      case ResizeDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.topRight:
      case ResizeDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case ResizeDirection.left:
      case ResizeDirection.right:
        return SystemMouseCursors.resizeLeftRight;
      case ResizeDirection.top:
      case ResizeDirection.bottom:
        return SystemMouseCursors.resizeUpDown;
      case ResizeDirection.none:
        return SystemMouseCursors.basic;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _position ??= Offset(
        screenSize.width / 2 - _width / 2, screenSize.height / 2 - _height / 2);

    return Positioned(
      top: _position!.dy,
      left: _position!.dx,
      child: MouseRegion(
        cursor: _getCursor(_resizeDirection),
        onHover: (event) {
          if (!_isResizing) {
            setState(() {
              _resizeDirection = _getResizeDirection(event.localPosition);
            });
          }
        },
        onExit: (event) {
          if (!_isResizing) {
            setState(() {
              _resizeDirection = ResizeDirection.none;
            });
          }
        },
        child: GestureDetector(
          onPanStart: (details) {
            final resizeDir = _getResizeDirection(details.localPosition);
            setState(() {
              if (resizeDir != ResizeDirection.none) {
                _isResizing = true;
                _resizeDirection = resizeDir;
              }
            });
          },
          onPanUpdate: (details) {
            if (_isResizing) {
              setState(() {
                _handleResize(details.delta);
              });
            }
          },
          onPanEnd: (details) {
            setState(() {
              _isResizing = false;
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Draggable(
                feedback: SizedBox(
                  width: _width,
                  height: _height,
                  child: widget.child,
                ),
                onDragStarted: () {
                  // Only start dragging if we're not resizing
                  if (!_isResizing) {
                    setState(() {
                      if (!_started) _started = true;
                    });
                  }
                },
                onDragEnd: (details) {
                  final screenSize = MediaQuery.of(context).size;
                  // Calculate the proposed new position
                  final newPosition = details.offset;

                  // Calculate the bounds
                  final maxX = screenSize.width - _width;
                  final maxY = screenSize.height - _height;

                  // Constrain the position within the screen bounds
                  final constrainedX = newPosition.dx.clamp(0.0, maxX);
                  final constrainedY = newPosition.dy.clamp(0.0, maxY);

                  setState(() {
                    if (_started) _started = false;
                    _position = Offset(constrainedX, constrainedY);
                  });
                },
                child: SizedBox(
                  width: _width,
                  height: _height,
                  child: _started
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            widget.child,
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: _height,
                              width: _width,
                            )
                          ],
                        )
                      : widget.child,
                ),
              ),
              // macOS window control buttons
              if (!_started) _buildMacOSButtons(),
              // Corner resize handles
              ..._buildCornerHandles(),
              // Edge resize handles
              ..._buildEdgeHandles(),
            ],
          ),
        ),
      ),
    );
  }

  // Build macOS style window control buttons
  Widget _buildMacOSButtons() {
    return Positioned(
      top: _buttonMargin,
      left: _buttonMargin,
      child: Row(
        children: [
          // Close button (Red)
          MouseRegion(
            onEnter: (_) => setState(() => _isRedHovered = true),
            onExit: (_) => setState(() => _isRedHovered = false),
            child: GestureDetector(
              onTap: _handleClose,
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(_buttonSize / 2),
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
          SizedBox(width: _buttonSpacing),
          // Minimize button (Yellow)
          MouseRegion(
            onEnter: (_) => setState(() => _isYellowHovered = true),
            onExit: (_) => setState(() => _isYellowHovered = false),
            child: GestureDetector(
              onTap: _handleMinimize,
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(_buttonSize / 2),
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
          SizedBox(width: _buttonSpacing),
          // Maximize button (Green)
          MouseRegion(
            onEnter: (_) => setState(() => _isGreenHovered = true),
            onExit: (_) => setState(() => _isGreenHovered = false),
            child: GestureDetector(
              onTap: _handleMaximize,
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(_buttonSize / 2),
                  border: Border.all(
                    color: Colors.green.shade800,
                    width: 0.5,
                  ),
                ),
                child: _isGreenHovered
                    ? Icon(
                        Icons.unfold_more,
                        size: 8,
                        color: Colors.black54,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handler for close button
  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  // Handler for minimize button
  void _handleMinimize() {
    // setState(() {
    //   if (_isMinimized) {
    //     // Restore
    //     _height = _originalSize?.height ?? 240;
    //     _isMinimized = false;
    //   } else {
    //     // Minimize
    //     _originalSize = Size(_width, _height);
    //     _height = 40; // Minimize to just show the title bar
    //     _isMinimized = true;

    //     // If maximized, un-maximize
    //     if (_isMaximized) {
    //       _handleMaximize();
    //     }
    //   }
    // });
  }

  // Handler for maximize button
  void _handleMaximize() {
    // final screenSize = MediaQuery.of(context).size;

    // setState(() {
    //   if (_isMaximized) {
    //     // Restore original size and position
    //     _width = _originalSize?.width ?? 440;
    //     _height = _originalSize?.height ?? 240;
    //     _position = _originalPosition;
    //     _isMaximized = false;
    //   } else {
    //     // Save original size and position
    //     _originalSize = Size(_width, _height);
    //     _originalPosition = _position;

    //     // Maximize to screen size
    //     _width = screenSize.width;
    //     _height = screenSize.height;
    //     _position = const Offset(0, 0);
    //     _isMaximized = true;

    //     // If minimized, un-minimize
    //     _isMinimized = false;
    //   }
    // });
  }

  // Get the direction to resize based on mouse position
  ResizeDirection _getResizeDirection(Offset localPosition) {
    final isTop = localPosition.dy < _handleSize;
    final isBottom = localPosition.dy > _height - _handleSize;
    final isLeft = localPosition.dx < _handleSize;
    final isRight = localPosition.dx > _width - _handleSize;

    // Check corners first
    if (isTop && isLeft) return ResizeDirection.topLeft;
    if (isTop && isRight) return ResizeDirection.topRight;
    if (isBottom && isLeft) return ResizeDirection.bottomLeft;
    if (isBottom && isRight) return ResizeDirection.bottomRight;

    // Then check edges
    if (isTop) return ResizeDirection.top;
    if (isBottom) return ResizeDirection.bottom;
    if (isLeft) return ResizeDirection.left;
    if (isRight) return ResizeDirection.right;

    return ResizeDirection.none;
  }

  // Handle the resize operation based on the direction
  void _handleResize(Offset delta) {
    const minWidth = 200.0;
    const minHeight = 150.0;

    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    // Set maximum width and height to screen dimensions
    final maxWidth = screenSize.width;
    final maxHeight = screenSize.height;

    switch (_resizeDirection) {
      case ResizeDirection.topLeft:
        final newWidth = _width - delta.dx;
        final newHeight = _height - delta.dy;
        final newX = _position!.dx + delta.dx;
        final newY = _position!.dy + delta.dy;

        // Apply constraints with absolute limits
        if (newWidth >= minWidth && newWidth <= maxWidth && newX >= 0) {
          _width = newWidth;
          _position = Offset(newX, _position!.dy);
        }

        if (newHeight >= minHeight && newHeight <= maxHeight && newY >= 0) {
          _height = newHeight;
          _position = Offset(_position!.dx, newY);
        }
        break;

      case ResizeDirection.topRight:
        final newWidth = _width + delta.dx;
        final newHeight = _height - delta.dy;
        final newY = _position!.dy + delta.dy;

        // Apply constraints with absolute limits
        if (newWidth >= minWidth && newWidth <= maxWidth) {
          _width = newWidth;
        }

        if (newHeight >= minHeight && newHeight <= maxHeight && newY >= 0) {
          _height = newHeight;
          _position = Offset(_position!.dx, newY);
        }
        break;

      case ResizeDirection.bottomLeft:
        final newWidth = _width - delta.dx;
        final newHeight = _height + delta.dy;
        final newX = _position!.dx + delta.dx;

        // Apply constraints with absolute limits
        if (newWidth >= minWidth && newWidth <= maxWidth && newX >= 0) {
          _width = newWidth;
          _position = Offset(newX, _position!.dy);
        }

        if (newHeight >= minHeight && newHeight <= maxHeight) {
          _height = newHeight;
        }
        break;

      case ResizeDirection.bottomRight:
        final newWidth = _width + delta.dx;
        final newHeight = _height + delta.dy;

        // Apply constraints with absolute limits
        if (newWidth >= minWidth && newWidth <= maxWidth) {
          _width = newWidth;
        }

        if (newHeight >= minHeight && newHeight <= maxHeight) {
          _height = newHeight;
        }
        break;

      case ResizeDirection.left:
        final newWidth = _width - delta.dx;
        final newX = _position!.dx + delta.dx;

        // Apply constraints with absolute limits
        if (newWidth >= minWidth && newWidth <= maxWidth && newX >= 0) {
          _width = newWidth;
          _position = Offset(newX, _position!.dy);
        }
        break;

      case ResizeDirection.right:
        final newWidth = _width + delta.dx;

        // Apply constraints with absolute limits
        if (newWidth >= minWidth && newWidth <= maxWidth) {
          _width = newWidth;
        }
        break;

      case ResizeDirection.top:
        final newHeight = _height - delta.dy;
        final newY = _position!.dy + delta.dy;

        // Apply constraints with absolute limits
        if (newHeight >= minHeight && newHeight <= maxHeight && newY >= 0) {
          _height = newHeight;
          _position = Offset(_position!.dx, newY);
        }
        break;

      case ResizeDirection.bottom:
        final newHeight = _height + delta.dy;

        // Apply constraints with absolute limits
        if (newHeight >= minHeight && newHeight <= maxHeight) {
          _height = newHeight;
        }
        break;

      case ResizeDirection.none:
        break;
    }

    // After resize, ensure container stays within screen bounds
    _ensureContainerWithinScreen(screenSize);
  }

  // Helper method to ensure container is within screen bounds after resize
  void _ensureContainerWithinScreen(Size screenSize) {
    // If container is off the right edge
    if (_position!.dx + _width > screenSize.width) {
      _position = Offset(screenSize.width - _width, _position!.dy);
    }

    // If container is off the bottom edge
    if (_position!.dy + _height > screenSize.height) {
      _position = Offset(_position!.dx, screenSize.height - _height);
    }

    // If container is off the left edge (shouldn't happen, but just in case)
    if (_position!.dx < 0) {
      _position = Offset(0, _position!.dy);
    }

    // If container is off the top edge (shouldn't happen, but just in case)
    if (_position!.dy < 0) {
      _position = Offset(_position!.dx, 0);
    }
  }

  // Build all corner resize handles
  List<Widget> _buildCornerHandles() {
    return [
      _buildHandle(
          0, 0, _cornerHandleSize, _cornerHandleSize, Alignment.topLeft),
      _buildHandle(_width - _cornerHandleSize, 0, _cornerHandleSize,
          _cornerHandleSize, Alignment.topRight),
      _buildHandle(0, _height - _cornerHandleSize, _cornerHandleSize,
          _cornerHandleSize, Alignment.bottomLeft),
      _buildHandle(_width - _cornerHandleSize, _height - _cornerHandleSize,
          _cornerHandleSize, _cornerHandleSize, Alignment.bottomRight),
    ];
  }

  // Build all edge resize handles
  List<Widget> _buildEdgeHandles() {
    return [
      // Top edge
      _buildHandle(_cornerHandleSize, 0, _width - 2 * _cornerHandleSize,
          _handleSize, Alignment.topCenter),
      // Left edge
      _buildHandle(0, _cornerHandleSize, _handleSize,
          _height - 2 * _cornerHandleSize, Alignment.centerLeft),
      // Right edge
      _buildHandle(_width - _handleSize, _cornerHandleSize, _handleSize,
          _height - 2 * _cornerHandleSize, Alignment.centerRight),
      // Bottom edge
      _buildHandle(_cornerHandleSize, _height - _handleSize,
          _width - 2 * _cornerHandleSize, _handleSize, Alignment.bottomCenter),
    ];
  }

  // Helper method to build a single resize handle
  Widget _buildHandle(double left, double top, double width, double height,
      Alignment alignment) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _resizeDirection != ResizeDirection.none
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          border: _resizeDirection != ResizeDirection.none
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
              : null,
        ),
      ),
    );
  }
}

// Enum to track resize direction
enum ResizeDirection {
  none,
  top,
  right,
  bottom,
  left,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
