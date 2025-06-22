import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/animation_service.dart';
import '../../../export/presentation/export_screen.dart';
import '../../../import/import_dialog.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'filter_dropdown.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardState state;

  const DashboardHeader({super.key, required this.state});

  void _navigateToExport(BuildContext context) {
    AnimationService.navigateWithAnimation(
      context: context,
      page: const ExportScreen(),
      type: AnimationType.slideLeft,
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const ImportDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isSmallScreen = screenWidth < 380;

              if (isSmallScreen) {
                // For very small screens, use a Column layout
                return Column(
                  children: [
                    // User info row
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Shihab Rahman',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Actions row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () => _showImportDialog(context),
                                icon: const Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                tooltip: 'Import',
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () => _navigateToExport(context),
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                tooltip: 'Export',
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Filter Dropdown
                        Flexible(
                          child: FilterDropdown(
                            selectedFilter: state is DashboardLoaded
                                ? (state as DashboardLoaded)
                                      .summary
                                      .selectedDateFilter
                                : 'This Month',
                            onFilterChanged: (filter) {
                              context.read<DashboardBloc>().add(
                                UpdateDateFilter(filter),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              // For normal screens, use horizontal layout
              return Row(
                children: [
                  // User info section - Flexible to take available space
                  Flexible(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Shihab Rahman',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Actions section - Fixed width to prevent overflow
                  SizedBox(
                    width: screenWidth < 450 ? 180 : 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Export/Import buttons
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _showImportDialog(context),
                            icon: const Icon(
                              Icons.upload_file,
                              color: Colors.white,
                              size: 18,
                            ),
                            tooltip: 'Import Data',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _navigateToExport(context),
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 18,
                            ),
                            tooltip: 'Export Data',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Filter Dropdown - Flexible within the fixed container
                        Flexible(
                          child: FilterDropdown(
                            selectedFilter: state is DashboardLoaded
                                ? (state as DashboardLoaded)
                                      .summary
                                      .selectedDateFilter
                                : 'This Month',
                            onFilterChanged: (filter) {
                              context.read<DashboardBloc>().add(
                                UpdateDateFilter(filter),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
