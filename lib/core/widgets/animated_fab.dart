import 'package:flutter/material.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool mini;

  const AnimatedFloatingActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.mini = false,
  });

  @override
  State<AnimatedFloatingActionButton> createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Start the entrance animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handlePress() {
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: FloatingActionButton(
          onPressed: _handlePress,
          backgroundColor: widget.backgroundColor ?? Colors.blue,
          foregroundColor: widget.foregroundColor ?? Colors.white,
          tooltip: widget.tooltip,
          mini: widget.mini,
          elevation: 8,
          child: widget.child,
        ),
      ),
    );
  }
}

class ExpandableFAB extends StatefulWidget {
  final List<FABItem> items;
  final Widget mainIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double distance;

  const ExpandableFAB({
    super.key,
    required this.items,
    required this.mainIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.distance = 70.0,
  });

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56 + (widget.items.length * widget.distance),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Backdrop
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: Opacity(
                  opacity: _expandAnimation.value * 0.3,
                  child: GestureDetector(
                    onTap: _isExpanded ? _toggle : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Sub FABs
          ...widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final offset = (index + 1) * widget.distance;

            return AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: 56 + (offset * _expandAnimation.value),
                  child: Transform.scale(
                    scale: _expandAnimation.value,
                    child: Opacity(
                      opacity: _expandAnimation.value,
                      child: FloatingActionButton(
                        heroTag: 'fab_$index',
                        mini: true,
                        onPressed: () {
                          _toggle();
                          item.onPressed();
                        },
                        backgroundColor:
                            item.backgroundColor ?? Colors.blue[600],
                        foregroundColor: item.foregroundColor ?? Colors.white,
                        tooltip: item.tooltip,
                        child: item.icon,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main FAB
          Positioned(
            bottom: 0,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                heroTag: 'main_fab',
                onPressed: _toggle,
                backgroundColor: widget.backgroundColor ?? Colors.blue,
                foregroundColor: widget.foregroundColor ?? Colors.white,
                elevation: 8,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isExpanded
                      ? const Icon(Icons.close, key: ValueKey('close'))
                      : widget.mainIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FABItem {
  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FABItem({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}

class PulsatingFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool shouldPulse;

  const PulsatingFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.shouldPulse = true,
  });

  @override
  State<PulsatingFAB> createState() => _PulsatingFABState();
}

class _PulsatingFABState extends State<PulsatingFAB>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.shouldPulse) {
      _startPulsing();
    }
  }

  void _startPulsing() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulsing() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  void didUpdateWidget(PulsatingFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulse != oldWidget.shouldPulse) {
      if (widget.shouldPulse) {
        _startPulsing();
      } else {
        _stopPulsing();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.shouldPulse ? _pulseAnimation.value : 1.0,
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: widget.backgroundColor ?? Colors.blue,
            foregroundColor: widget.foregroundColor ?? Colors.white,
            elevation: 8,
            child: widget.child,
          ),
        );
      },
    );
  }
}
