import 'package:flutter/material.dart';

class ProjectsLoadingShimmer extends StatefulWidget {
  const ProjectsLoadingShimmer({super.key});

  @override
  State<ProjectsLoadingShimmer> createState() => _ProjectsLoadingShimmerState();
}

class _ProjectsLoadingShimmerState extends State<ProjectsLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    double? width,
    required double height,
    double radius = 12,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.6),
              _controller.value,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 150, height: 32),
                    const SizedBox(height: 8),
                    _shimmerBox(width: 250, height: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Team Grid Shimmer (Matching the new GridView)
          _shimmerBox(width: 120, height: 24), // "The Squad" title
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (context, index) =>
                _shimmerBox(height: 100, radius: 20),
          ),

          const SizedBox(height: 32),

          // Timeline Shimmer
          _shimmerBox(width: 140, height: 24), // "Roadmap" title
          const SizedBox(height: 16),
          Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    _shimmerBox(width: 20, height: 20, radius: 10),
                    const SizedBox(width: 16),
                    Expanded(child: _shimmerBox(height: 100, radius: 16)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
