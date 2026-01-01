import 'package:flutter/material.dart';

/// Professional page transitions
enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
  fadeScale,
}

class SmoothPageTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType type;
  final Duration duration;
  final Curve curve;

  SmoothPageTransition({
    required this.page,
    this.type = TransitionType.fadeScale,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              type,
              animation,
              secondaryAnimation,
              child,
              curve,
            );
          },
        );

  static Widget _buildTransition(
    TransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );

      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case TransitionType.fadeScale:
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

/// Helper extension for easy navigation
extension NavigationExtension on BuildContext {
  Future<T?> pushSmooth<T>(
    Widget page, {
    TransitionType type = TransitionType.fadeScale,
  }) {
    return Navigator.of(this).push<T>(
      SmoothPageTransition<T>(page: page, type: type),
    );
  }

  Future<T?> pushReplacementSmooth<T>(
    Widget page, {
    TransitionType type = TransitionType.fadeScale,
  }) {
    return Navigator.of(this).pushReplacement<T, void>(
      SmoothPageTransition<T>(page: page, type: type),
    );
  }
}
