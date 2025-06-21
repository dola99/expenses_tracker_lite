import 'package:flutter/material.dart';

enum AnimationType {
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  fade,
  scale,
  slideAndFade,
  scaleAndFade,
  rotation,
  custom,
}

class AnimationService {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOut;

  /// Create a page route with custom animation
  static PageRouteBuilder<T> createAnimatedRoute<T>({
    required Widget page,
    AnimationType type = AnimationType.slideLeft,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Offset? beginOffset,
    Offset? endOffset,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          type: type,
          curve: curve,
          beginOffset: beginOffset,
          endOffset: endOffset,
        );
      },
    );
  }

  /// Navigate with animation
  static Future<T?> navigateWithAnimation<T>({
    required BuildContext context,
    required Widget page,
    AnimationType type = AnimationType.slideLeft,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    bool replace = false,
  }) {
    final route = createAnimatedRoute<T>(
      page: page,
      type: type,
      duration: duration,
      curve: curve,
    );

    if (replace) {
      return Navigator.pushReplacement<T, dynamic>(context, route);
    } else {
      return Navigator.push<T>(context, route);
    }
  }

  /// Create an animated container transition
  static Widget animatedContainer({
    required Widget child,
    required AnimationController controller,
    AnimationType type = AnimationType.slideUp,
    Duration delay = Duration.zero,
    Curve curve = defaultCurve,
  }) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay.inMilliseconds / controller.duration!.inMilliseconds,
        1.0,
        curve: curve,
      ),
    );

    return _buildAnimatedWidget(animation: animation, child: child, type: type);
  }

  /// Create staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 100),
    AnimationType type = AnimationType.slideUp,
    Curve curve = defaultCurve,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = Duration(
          milliseconds: index * staggerDelay.inMilliseconds,
        );

        return animatedContainer(
          child: child,
          controller: controller,
          type: type,
          delay: delay,
          curve: curve,
        );
      }).toList(),
    );
  }

  /// Create a floating action button with scale animation
  static Widget animatedFAB({
    required Widget child,
    required AnimationController controller,
    VoidCallback? onPressed,
    Duration delay = Duration.zero,
  }) {
    final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.inMilliseconds / controller.duration!.inMilliseconds,
          1.0,
          curve: Curves.elasticOut,
        ),
      ),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: FloatingActionButton(onPressed: onPressed, child: child),
    );
  }

  /// Create a loading animation
  static Widget loadingAnimation({double size = 50.0, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
        strokeWidth: 3.0,
      ),
    );
  }

  /// Create a custom hero animation
  static Widget heroAnimation({
    required String tag,
    required Widget child,
    Duration duration = defaultDuration,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            return ScaleTransition(scale: animation, child: child);
          },
      child: child,
    );
  }

  /// Private method to build transitions
  static Widget _buildTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required AnimationType type,
    required Curve curve,
    Offset? beginOffset,
    Offset? endOffset,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case AnimationType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset ?? const Offset(0.0, 1.0),
            end: endOffset ?? Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case AnimationType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset ?? const Offset(0.0, -1.0),
            end: endOffset ?? Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case AnimationType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset ?? const Offset(1.0, 0.0),
            end: endOffset ?? Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case AnimationType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset ?? const Offset(-1.0, 0.0),
            end: endOffset ?? Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case AnimationType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case AnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: child,
        );

      case AnimationType.slideAndFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset ?? const Offset(0.0, 0.3),
            end: endOffset ?? Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case AnimationType.scaleAndFade:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case AnimationType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: child,
        );

      case AnimationType.custom:
        return FadeTransition(opacity: curvedAnimation, child: child);
    }
  }

  /// Private method to build animated widgets
  static Widget _buildAnimatedWidget({
    required Animation<double> animation,
    required Widget child,
    required AnimationType type,
  }) {
    switch (type) {
      case AnimationType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );

      case AnimationType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );

      case AnimationType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.5, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );

      case AnimationType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.5, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );

      case AnimationType.fade:
        return FadeTransition(opacity: animation, child: child);

      case AnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );

      case AnimationType.slideAndFade:
      case AnimationType.scaleAndFade:
      case AnimationType.rotation:
      case AnimationType.custom:
        return FadeTransition(opacity: animation, child: child);
    }
  }
}
