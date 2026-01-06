import 'package:flutter/material.dart';

class ProfileLoadingShimmer extends StatefulWidget {
  const ProfileLoadingShimmer({super.key});

  @override
  State<ProfileLoadingShimmer> createState() => _ProfileLoadingShimmerState();
}

class _ProfileLoadingShimmerState extends State<ProfileLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderShimmer(context),
                _buildContentShimmer(context),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
                colorScheme.surfaceContainerHighest.withOpacity(0.6),
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(width: 80, height: 28),
                  Row(
                    children: [
                      _buildShimmerBox(width: 40, height: 40, borderRadius: 20),
                      const SizedBox(width: 8),
                      _buildShimmerBox(width: 40, height: 40, borderRadius: 20),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar shimmer
              _buildShimmerBox(width: 106, height: 106, borderRadius: 53),

              const SizedBox(height: 16),

              // Name shimmer
              _buildShimmerBox(width: 150, height: 24),

              const SizedBox(height: 8),

              // Email shimmer
              _buildShimmerBox(width: 200, height: 16),

              const SizedBox(height: 12),

              // Bio shimmer
              _buildShimmerBox(width: 250, height: 14),

              const SizedBox(height: 20),

              // Edit button shimmer
              _buildShimmerBox(width: 120, height: 36, borderRadius: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row shimmer
          Row(
            children: [
              Expanded(child: _buildStatCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCardShimmer()),
            ],
          ),

          const SizedBox(height: 28),

          // Skills section shimmer
          _buildSectionShimmer(title: true, chipCount: 5),

          const SizedBox(height: 28),

          // Info section shimmer
          _buildInfoSectionShimmer(),

          const SizedBox(height: 28),

          // Account section shimmer
          _buildAccountSectionShimmer(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatCardShimmer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildShimmerBox(width: 22, height: 22, borderRadius: 4),
          const SizedBox(height: 8),
          _buildShimmerBox(width: 30, height: 24),
          const SizedBox(height: 4),
          _buildShimmerBox(width: 50, height: 12),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer({bool title = true, int chipCount = 4}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(width: 60, height: 20),
              _buildShimmerBox(width: 50, height: 16),
            ],
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            chipCount,
            (index) => _buildShimmerBox(
              width: 60.0 + (index * 15) % 40,
              height: 32,
              borderRadius: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSectionShimmer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(width: 100, height: 20),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildInfoTileShimmer(),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
              _buildInfoTileShimmer(),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
              _buildInfoTileShimmer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTileShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildShimmerBox(width: 20, height: 20, borderRadius: 4),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(width: 50, height: 12),
                const SizedBox(height: 4),
                _buildShimmerBox(width: 150, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSectionShimmer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(width: 80, height: 20),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildActionTileShimmer(),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
              _buildActionTileShimmer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTileShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildShimmerBox(width: 20, height: 20, borderRadius: 4),
          const SizedBox(width: 14),
          Expanded(child: _buildShimmerBox(width: 120, height: 16)),
          _buildShimmerBox(width: 20, height: 20, borderRadius: 4),
        ],
      ),
    );
  }
}
