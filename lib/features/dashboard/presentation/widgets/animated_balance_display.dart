import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class AnimatedBalanceDisplay extends StatefulWidget {
  final double balance;
  final Duration animationDuration;

  const AnimatedBalanceDisplay({
    super.key,
    required this.balance,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedBalanceDisplay> createState() => _AnimatedBalanceDisplayState();
}

class _AnimatedBalanceDisplayState extends State<AnimatedBalanceDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Color _currentColor = AppTheme.balanceNeutral;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _updateBalanceColor();
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBalanceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _updateBalanceColor();
      _animateToNewBalance();
    }
  }

  void _updateBalanceColor() {
    setState(() {
      _currentColor = _getBalanceColor(widget.balance);
    });
  }

  void _animateToNewBalance() {
    _controller.reset();
    _controller.forward();
  }

  Color _getBalanceColor(double balance) {
    if (balance > 5000) {
      // Positive balance - Green
      return AppTheme.balancePositive;
    } else if (balance < 0) {
      // Negative balance - Red
      return AppTheme.balanceNegative;
    } else if (balance >= 4000 && balance <= 6000) {
      // Around average (5000) - Blue
      return AppTheme.balanceAverage;
    } else {
      // Low positive balance - Gray
      return AppTheme.balanceNeutral;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  // Balance status indicator with colored dot
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _currentColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Balance text with white color
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(widget.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Balance status icon in white
                  Icon(
                    _getBalanceIcon(widget.balance),
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getBalanceIcon(double balance) {
    if (balance > 5000) {
      return Icons.trending_up;
    } else if (balance < 0) {
      return Icons.trending_down;
    } else if (balance >= 4000 && balance <= 6000) {
      return Icons.timeline;
    } else {
      return Icons.trending_flat;
    }
  }
}
