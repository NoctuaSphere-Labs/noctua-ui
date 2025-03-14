import 'dart:async';

import 'package:flutter/material.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:game_ui/utils/web_draggable.dart';
import 'package:game_ui/widgets/app_window_buttons.dart';

class DraggableContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onClose;
  final double? parentWidth;
  final double? parentHeight;

  const DraggableContainer({
    super.key,
    required this.child,
    this.onClose,
    this.parentWidth,
    this.parentHeight,
  });

  @override
  State<DraggableContainer> createState() => _DraggableContainerState();
}

class _DraggableContainerState extends State<DraggableContainer> {
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;

  double _width = 440;
  double _height = 240;
  bool _isResizing = false;
  ResizeDirection _resizeDirection = ResizeDirection.none;
  bool _isMinimized = false;
  bool _isMaximized = false;
  Size? _originalSize;
  StreamController<Offset> lastDraggedPosition =
      StreamController<Offset>.broadcast();
  final StreamController<Offset> mousePositionController =
      StreamController<Offset>.broadcast();

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
  void initState() {
    lastDraggedPosition.stream.listen((offset) {
      _position = offset;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        mousePositionController.add(event.localPosition);
      },
      child: Stack(
        children: [
          StreamBuilder<Offset>(
              stream: lastDraggedPosition.stream,
              builder: (context, snapshot) {
                return Positioned(
                  top: snapshot.data?.dy ?? _position.dy,
                  left: snapshot.data?.dx ?? _position.dx,
                  child: MouseRegion(
                    cursor: _getCursor(_resizeDirection),
                    onHover: (event) {
                      if (!_isResizing) {
                        setState(() {
                          _resizeDirection =
                              _getResizeDirection(event.localPosition);
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
                        final resizeDir =
                            _getResizeDirection(details.localPosition);
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
                          WebDraggable(
                            parentWidth: widget.parentWidth!,
                            parentHeight: widget.parentHeight!,
                            width: _width,
                            height: _height,
                            shouldDrag: !_isResizing,
                            lastDraggedPosition: lastDraggedPosition,
                            mousePositionController:
                                mousePositionController.stream,
                            isDraggingListener: (isDragging) {
                              setState(() {
                                _isDragging = isDragging;
                              });
                            },
                            child: widget.child,
                          ),
                          // macOS window control buttons
                          if (!_isDragging)
                            const Positioned(
                              top: 32,
                              left: 32,
                              child: AppWindowButtons(),
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
              }),
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
    setState(() {
      if (_isMinimized) {
        // Restore
        _height = _originalSize?.height ?? 240;
        _isMinimized = false;
      } else {
        // Minimize
        _originalSize = Size(_width, _height);
        _height = 40; // Minimize to just show the title bar
        _isMinimized = true;

        // If maximized, un-maximize
        if (_isMaximized) {
          _handleMaximize();
        }
      }
    });
  }

  // Handler for maximize button
  void _handleMaximize() {
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      if (_isMaximized) {
        // Restore original size and position
        _width = _originalSize?.width ?? 440;
        _height = _originalSize?.height ?? 240;
        // _position = _originalPosition;
        _isMaximized = false;
      } else {
        // Save original size and position
        _originalSize = Size(_width, _height);
        // _originalPosition = _position;

        // Maximize to screen size
        _width = screenSize.width;
        _height = screenSize.height;
        _position = const Offset(0, 0);
        _isMaximized = true;

        // If minimized, un-minimize
        _isMinimized = false;
      }
    });
  }

  // Helper to extract and modify child content when maximized
  Widget _wrapChildForMaximized() {
    // Check if the child is a padding with BlurryContainer
    if (widget.child is Padding) {
      final paddingWidget = widget.child as Padding;
      final paddingValue = paddingWidget.padding;

      // Extract the ListView or other content from the BlurryContainer
      if (paddingWidget.child is BlurryContainer) {
        final blurryContainer = paddingWidget.child as BlurryContainer;

        // Return a normal Container with the same padding and the BlurryContainer's child
        return Padding(
          padding: paddingValue,
          child: Container(
            padding: blurryContainer.padding,
            child: blurryContainer.child,
          ),
        );
      }
    }

    // If we couldn't extract the content, just return the original child
    return widget.child;
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
