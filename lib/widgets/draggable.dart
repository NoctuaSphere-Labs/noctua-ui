import 'package:flutter/material.dart';

class DraggableContainer extends StatefulWidget {
  final Widget child;
  final Widget feedback;

  const DraggableContainer({
    super.key,
    required this.child,
    required this.feedback,
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
                  child: _started ? widget.feedback : widget.child,
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
                  child: _started ? widget.feedback : widget.child,
                ),
              ),
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

    switch (_resizeDirection) {
      case ResizeDirection.topLeft:
        final newWidth = _width - delta.dx;
        final newHeight = _height - delta.dy;
        if (newWidth >= minWidth) {
          _width = newWidth;
          _position = Offset(_position!.dx + delta.dx, _position!.dy);
        }
        if (newHeight >= minHeight) {
          _height = newHeight;
          _position = Offset(_position!.dx, _position!.dy + delta.dy);
        }
        break;
      case ResizeDirection.topRight:
        final newWidth = _width + delta.dx;
        final newHeight = _height - delta.dy;
        if (newWidth >= minWidth) {
          _width = newWidth;
        }
        if (newHeight >= minHeight) {
          _height = newHeight;
          _position = Offset(_position!.dx, _position!.dy + delta.dy);
        }
        break;
      case ResizeDirection.bottomLeft:
        final newWidth = _width - delta.dx;
        final newHeight = _height + delta.dy;
        if (newWidth >= minWidth) {
          _width = newWidth;
          _position = Offset(_position!.dx + delta.dx, _position!.dy);
        }
        if (newHeight >= minHeight) {
          _height = newHeight;
        }
        break;
      case ResizeDirection.bottomRight:
        final newWidth = _width + delta.dx;
        final newHeight = _height + delta.dy;
        if (newWidth >= minWidth) {
          _width = newWidth;
        }
        if (newHeight >= minHeight) {
          _height = newHeight;
        }
        break;
      case ResizeDirection.left:
        final newWidth = _width - delta.dx;
        if (newWidth >= minWidth) {
          _width = newWidth;
          _position = Offset(_position!.dx + delta.dx, _position!.dy);
        }
        break;
      case ResizeDirection.right:
        final newWidth = _width + delta.dx;
        if (newWidth >= minWidth) {
          _width = newWidth;
        }
        break;
      case ResizeDirection.top:
        final newHeight = _height - delta.dy;
        if (newHeight >= minHeight) {
          _height = newHeight;
          _position = Offset(_position!.dx, _position!.dy + delta.dy);
        }
        break;
      case ResizeDirection.bottom:
        final newHeight = _height + delta.dy;
        if (newHeight >= minHeight) {
          _height = newHeight;
        }
        break;
      case ResizeDirection.none:
        break;
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
