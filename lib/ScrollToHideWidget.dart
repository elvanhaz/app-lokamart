import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollToHideWidget extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final Duration duration;

  const ScrollToHideWidget({super.key, 
    required this.child,
    required this.controller,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  _ScrollToHideWidgetState createState() => _ScrollToHideWidgetState();
}

class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
  bool isVisible = true;
  bool isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(listen);
    super.dispose();
  }

  void listen() {
    if (widget.controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (!isScrollingDown) {
        setState(() {
          isScrollingDown = true;
          isVisible = false;
        });
      }
    } else if (widget.controller.position.userScrollDirection == ScrollDirection.forward) {
      if (isScrollingDown) {
        setState(() {
          isScrollingDown = false;
          isVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      height: isVisible ? kBottomNavigationBarHeight : 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: widget.child,
      ),
    );
  }
}
