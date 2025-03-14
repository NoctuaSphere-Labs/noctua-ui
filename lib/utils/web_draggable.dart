import 'dart:async';

import 'package:flutter/material.dart';

class WebDraggable extends StatefulWidget {
  const WebDraggable({
    super.key,
    required this.parentWidth,
    required this.parentHeight,
    required this.width,
    required this.height,
    required this.child,
    required this.lastDraggedPosition,
    required this.mousePositionController,
    this.isDraggingListener,
    this.shouldDrag = true,
  });

  final double parentWidth;
  final double parentHeight;
  final double width;
  final double height;
  final Widget child;
  final bool shouldDrag;
  final StreamController<Offset> lastDraggedPosition;
  final Stream<Offset> mousePositionController;
  final Function(bool)? isDraggingListener;

  @override
  State<WebDraggable> createState() => _WebDraggableState();
}

class _WebDraggableState extends State<WebDraggable> {
  bool startedDragging = false;
  Offset mousePosition = const Offset(0, 0);
  Offset mousePositionInternal = const Offset(0, 0);
  final StreamController<Offset> mousePositionInternalController =
      StreamController<Offset>.broadcast();

  @override
  void initState() {
    super.initState();
    widget.mousePositionController.listen((offset) {
      setState(() {
        mousePosition = offset;
      });
    });
    mousePositionInternalController.stream.listen((offset) {
      setState(() {
        mousePositionInternal = offset;
      });
    });
  }

  void onDragStarted() {
    if (widget.shouldDrag) {
      widget.isDraggingListener?.call(true);
      setState(() {
        startedDragging = true;
      });
    }
  }

  double calculateXPosition() {
    final x = mousePosition.dx;
    final xDeltaMaxPixel = widget.parentWidth - widget.width;
    final xInternal = mousePositionInternal.dx;
    final xMousePosition = x - xInternal;
    final isOutOfBounds = xMousePosition > xDeltaMaxPixel;
    return isOutOfBounds ? xDeltaMaxPixel : xMousePosition;
  }

  double calculateYPosition() {
    final y = mousePosition.dy;
    final yDeltaMaxPixel = widget.parentHeight - widget.height;
    final yInternal = mousePositionInternal.dy;
    final yMousePosition = y - yInternal;
    final isOutOfBounds = yMousePosition > yDeltaMaxPixel;
    return isOutOfBounds ? yDeltaMaxPixel : yMousePosition;
  }

  void onDragEnd(DraggableDetails details) {
    debugPrint('onDragEnd: ${details.offset}');
    final maxWidth = widget.parentWidth - widget.width;
    final maxHeight = widget.parentHeight - widget.height;
    debugPrint('mousePosition now: $mousePosition');
    debugPrint('widget.width: ${widget.width}');
    debugPrint('widget.height: ${widget.height}');
    final newPosition = Offset(
      calculateXPosition(),
      calculateYPosition(),
    );
    debugPrint('newPosition: $newPosition');
    debugPrint('maxWidth: $maxWidth');
    debugPrint('maxHeight: $maxHeight');
    final constrainedX = newPosition.dx.clamp(0.0, maxWidth);
    final constrainedY = newPosition.dy.clamp(0.0, maxHeight);
    widget.lastDraggedPosition.add(Offset(
      constrainedX,
      constrainedY,
    ));
    widget.isDraggingListener?.call(false);
    setState(() {
      startedDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedBackWidget = Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(20),
          ),
          height: widget.height,
          width: widget.width,
        )
      ],
    );
    return MouseRegion(
      onHover: (event) {
        mousePositionInternalController.add(event.localPosition);
      },
      child: Draggable(
        feedback: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.child,
        ),
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: startedDragging
              ? feedBackWidget
              // If maximized, wrap child in a black Container
              : widget.parentWidth == widget.width &&
                      widget.parentHeight == widget.height
                  ? Container(
                      color: const Color(0xff212121),
                      child: Container(
                        child: widget.child,
                      ),
                    )
                  : widget.child,
        ),
      ),
    );
  }
}
