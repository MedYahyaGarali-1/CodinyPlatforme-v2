import 'package:flutter/material.dart';

/// A mixin that provides staggered fade-in and slide-up animations for screens.
/// 
/// Usage:
/// 1. Add `with StaggeredAnimationMixin` to your State class
/// 2. Add `TickerProviderStateMixin` to the mixins
/// 3. Call `initAnimations(sectionCount)` in initState()
/// 4. Call `disposeAnimations()` in dispose()
/// 5. Wrap sections with `buildAnimatedSection(index, child)`
/// 6. Call `restartAnimations()` after data loads to replay animations
mixin StaggeredAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  bool _animationsInitialized = false;

  /// Initialize animations with the given number of sections
  void initAnimations({int sectionCount = 6}) {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for each section
    _fadeAnimations = List.generate(sectionCount, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(sectionCount, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _animationsInitialized = true;
    // Don't auto-start, let data load first
  }

  /// Start or restart the animations (call after data loads)
  void startAnimations() {
    if (_animationsInitialized) {
      _staggerController.forward(from: 0.0);
    }
  }

  /// Dispose of the animation controller
  void disposeAnimations() {
    if (_animationsInitialized) {
      _staggerController.dispose();
    }
  }

  /// Wrap a section with staggered fade and slide animations
  Widget buildAnimatedSection(int index, Widget child) {
    if (!_animationsInitialized) return child;
    final safeIndex = index.clamp(0, _fadeAnimations.length - 1);
    return FadeTransition(
      opacity: _fadeAnimations[safeIndex],
      child: SlideTransition(
        position: _slideAnimations[safeIndex],
        child: child,
      ),
    );
  }
}

/// A simpler widget-based approach for staggered animations
class StaggeredAnimationWrapper extends StatefulWidget {
  final int index;
  final int totalItems;
  final Widget child;
  final Duration totalDuration;

  const StaggeredAnimationWrapper({
    super.key,
    required this.index,
    required this.child,
    this.totalItems = 6,
    this.totalDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<StaggeredAnimationWrapper> createState() => _StaggeredAnimationWrapperState();
}

class _StaggeredAnimationWrapperState extends State<StaggeredAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.totalDuration,
      vsync: this,
    );

    final start = (widget.index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
