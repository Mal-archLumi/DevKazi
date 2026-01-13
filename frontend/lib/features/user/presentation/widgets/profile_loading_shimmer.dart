// features/user/presentation/widgets/profile_loading_shimmer.dart
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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    Color? baseColor,
    Color? highlightColor,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Use provided colors or default to theme-appropriate ones
        final bgColor = baseColor ?? colorScheme.surfaceContainerHighest;
        final hlColor =
            highlightColor ??
            (isDark
                ? colorScheme.surface
                : colorScheme.primary.withOpacity(0.4));

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                bgColor.withOpacity(0.5),
                hlColor.withOpacity(0.8),
                bgColor.withOpacity(0.5),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
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
                  _buildShimmerBox(
                    width: 80,
                    height: 28,
                    baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    highlightColor: isDark
                        ? Colors.grey[600]
                        : Colors.grey[300],
                  ),
                  Row(
                    children: [
                      _buildShimmerBox(
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                        baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        highlightColor: isDark
                            ? Colors.grey[600]
                            : Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      _buildShimmerBox(
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                        baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        highlightColor: isDark
                            ? Colors.grey[600]
                            : Colors.grey[300],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar shimmer
              _buildShimmerBox(
                width: 106,
                height: 106,
                borderRadius: 53,
                baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
              ),

              const SizedBox(height: 16),

              // Name shimmer
              _buildShimmerBox(
                width: 150,
                height: 24,
                baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
              ),

              const SizedBox(height: 8),

              // Email shimmer
              _buildShimmerBox(
                width: 200,
                height: 16,
                baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
              ),

              const SizedBox(height: 12),

              // Bio shimmer
              _buildShimmerBox(
                width: 250,
                height: 14,
                baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
              ),

              const SizedBox(height: 20),

              // Edit button shimmer
              _buildShimmerBox(
                width: 120,
                height: 36,
                borderRadius: 20,
                baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
                highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills section shimmer
          _buildSectionShimmer(
            title: true,
            chipCount: 5,
            baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
            highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
          ),

          const SizedBox(height: 28),

          // Info section shimmer
          _buildInfoSectionShimmer(
            baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
            highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
          ),

          const SizedBox(height: 28),

          // Account section shimmer
          _buildAccountSectionShimmer(
            baseColor: isDark ? Colors.grey[800] : Colors.grey[200],
            highlightColor: isDark ? Colors.grey[600] : Colors.grey[300],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer({
    bool title = true,
    int chipCount = 4,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(
                width: 60,
                height: 20,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              _buildShimmerBox(
                width: 50,
                height: 16,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
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
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSectionShimmer({Color? baseColor, Color? highlightColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(
          width: 100,
          height: 20,
          baseColor: baseColor,
          highlightColor: highlightColor,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerLow.withOpacity(0.8)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildInfoTileShimmer(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
              _buildInfoTileShimmer(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
              _buildInfoTileShimmer(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTileShimmer({Color? baseColor, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildShimmerBox(
            width: 20,
            height: 20,
            borderRadius: 4,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(
                  width: 50,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                const SizedBox(height: 4),
                _buildShimmerBox(
                  width: 150,
                  height: 16,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSectionShimmer({
    Color? baseColor,
    Color? highlightColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(
          width: 80,
          height: 20,
          baseColor: baseColor,
          highlightColor: highlightColor,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerLow.withOpacity(0.8)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildActionTileShimmer(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
              _buildActionTileShimmer(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
              _buildActionTileShimmer(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTileShimmer({Color? baseColor, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildShimmerBox(
            width: 20,
            height: 20,
            borderRadius: 4,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildShimmerBox(
              width: 120,
              height: 16,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ),
          _buildShimmerBox(
            width: 20,
            height: 20,
            borderRadius: 4,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ],
      ),
    );
  }
}
