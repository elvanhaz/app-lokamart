import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HideOnScroll extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;
  final Duration duration;

  const HideOnScroll({super.key, 
    required this.child,
    required this.scrollController,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        double bottom = 0.0;
        if (scrollController.hasClients) {
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            bottom = -kBottomNavigationBarHeight;
          } else if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            bottom = 0.0;
          }
        }
        return Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          child: AnimatedContainer(
            duration: duration,
            height: kBottomNavigationBarHeight,
            child: this.child,
          ),
        );
      },
      child: child,
    );
  }
}
