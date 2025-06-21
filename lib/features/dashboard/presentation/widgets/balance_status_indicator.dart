import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class BalanceStatusIndicator extends StatelessWidget {
  final double currentBalance;
  final double averageAmount;

  const BalanceStatusIndicator({
    super.key,
    required this.currentBalance,
    this.averageAmount = 5000.0,
  });

  @override
  Widget build(BuildContext context) {
    final balanceStatus = _getBalanceStatus();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Status text
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: balanceStatus.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                balanceStatus.status,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(balanceStatus.icon, color: balanceStatus.color, size: 18),
            ],
          ),
          const SizedBox(height: 12),

          // Average line indicator
          _buildAverageLineIndicator(),

          const SizedBox(height: 8),

          // Balance comparison text
          Text(
            _getComparisonText(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  BalanceStatusInfo _getBalanceStatus() {
    if (currentBalance > averageAmount + 1000) {
      return BalanceStatusInfo(
        status: 'Excellent Balance',
        color: AppTheme.balancePositive,
        icon: Icons.trending_up,
      );
    } else if (currentBalance < 0) {
      return BalanceStatusInfo(
        status: 'Negative Balance',
        color: AppTheme.balanceNegative,
        icon: Icons.trending_down,
      );
    } else if (currentBalance >= averageAmount - 1000 &&
        currentBalance <= averageAmount + 1000) {
      return BalanceStatusInfo(
        status: 'Average Balance',
        color: AppTheme.balanceAverage,
        icon: Icons.timeline,
      );
    } else if (currentBalance > 0 && currentBalance < averageAmount - 1000) {
      return BalanceStatusInfo(
        status: 'Low Balance',
        color: AppTheme.balanceNeutral,
        icon: Icons.trending_flat,
      );
    } else {
      return BalanceStatusInfo(
        status: 'Good Balance',
        color: AppTheme.balancePositive,
        icon: Icons.trending_up,
      );
    }
  }

  Widget _buildAverageLineIndicator() {
    final progress = _calculateProgress();
    final balanceStatus = _getBalanceStatus();

    return Column(
      children: [
        Row(
          children: [
            Text(
              '\$0',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Text(
              'Avg',
              style: TextStyle(
                color: AppTheme.balanceAverage.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '>${CurrencyFormatter.format(averageAmount * 2)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Background line
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Progress line
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: balanceStatus.color,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: balanceStatus.color.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // Average marker
                Positioned(
                  left: constraints.maxWidth * 0.5 - 4, // Center position
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.balanceAverage,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  double _calculateProgress() {
    final maxValue = averageAmount * 2;
    if (currentBalance <= 0) return 0.0;
    if (currentBalance >= maxValue) return 1.0;
    return currentBalance / maxValue;
  }

  String _getComparisonText() {
    final difference = currentBalance - averageAmount;

    if (difference.abs() < 100) {
      return 'Your balance is around the average amount';
    } else if (difference > 0) {
      return '${CurrencyFormatter.format(difference)} above average';
    } else {
      return '${CurrencyFormatter.format(difference.abs())} below average';
    }
  }
}

class BalanceStatusInfo {
  final String status;
  final Color color;
  final IconData icon;

  BalanceStatusInfo({
    required this.status,
    required this.color,
    required this.icon,
  });
}
