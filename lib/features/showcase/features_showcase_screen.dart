import 'package:flutter/material.dart';
import '../../core/services/animation_service.dart';
import '../../core/widgets/animated_fab.dart';
import '../export/presentation/export_screen.dart';

class FeaturesShowcaseScreen extends StatefulWidget {
  const FeaturesShowcaseScreen({super.key});

  @override
  State<FeaturesShowcaseScreen> createState() => _FeaturesShowcaseScreenState();
}

class _FeaturesShowcaseScreenState extends State<FeaturesShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToExport() {
    AnimationService.navigateWithAnimation(
      context: context,
      page: const ExportScreen(),
      type: AnimationType.slideLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extra Features Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimationService.staggeredList(
          controller: _animationController,
          children: [
            // Header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Extra Features',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Animated transitions, CI/CD, and export functionality',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Feature Cards
            _buildFeatureCard(
              context,
              icon: Icons.download,
              title: 'Export Data',
              description: 'Export your transactions as PDF or CSV files',
              color: Colors.green,
              onTap: _navigateToExport,
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              icon: Icons.animation,
              title: 'Animated Transitions',
              description: 'Smooth animations throughout the app',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Animations are active throughout the app!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              icon: Icons.build,
              title: 'CI/CD Pipeline',
              description:
                  'Automated testing and deployment with GitHub Actions',
              color: Colors.orange,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('CI/CD Pipeline'),
                    content: const Text(
                      'The app includes a comprehensive GitHub Actions pipeline for:\n\n'
                      '• Automated testing\n'
                      '• Code analysis\n'
                      '• Multi-platform builds\n'
                      '• Automated deployment\n\n'
                      'Check the .github/workflows/ci.yml file for details.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Demo Buttons
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animation Demos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AnimationService.navigateWithAnimation(
                                context: context,
                                page: const _DemoScreen(title: 'Slide Left'),
                                type: AnimationType.slideLeft,
                              );
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Slide'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AnimationService.navigateWithAnimation(
                                context: context,
                                page: const _DemoScreen(title: 'Fade'),
                                type: AnimationType.fade,
                              );
                            },
                            icon: const Icon(Icons.blur_circular),
                            label: const Text('Fade'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AnimationService.navigateWithAnimation(
                            context: context,
                            page: const _DemoScreen(title: 'Scale & Fade'),
                            type: AnimationType.scaleAndFade,
                          );
                        },
                        icon: const Icon(Icons.zoom_in),
                        label: const Text('Scale & Fade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Showcase different FAB types
      floatingActionButton: ExpandableFAB(
        mainIcon: const Icon(Icons.add, key: ValueKey('add')),
        items: [
          FABItem(
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
            onPressed: _navigateToExport,
            backgroundColor: Colors.green,
          ),
          FABItem(
            icon: const Icon(Icons.animation),
            tooltip: 'Animation Demo',
            onPressed: () {
              AnimationService.navigateWithAnimation(
                context: context,
                page: const _DemoScreen(title: 'Animation Demo'),
                type: AnimationType.rotation,
              );
            },
            backgroundColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoScreen extends StatefulWidget {
  final String title;

  const _DemoScreen({required this.title});

  @override
  State<_DemoScreen> createState() => __DemoScreenState();
}

class __DemoScreenState extends State<_DemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: AnimationService.animatedContainer(
          controller: _controller,
          type: AnimationType.scaleAndFade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${widget.title} Animation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This screen was opened with a ${widget.title.toLowerCase()} animation!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.blue,
        tooltip: 'Go Back',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
