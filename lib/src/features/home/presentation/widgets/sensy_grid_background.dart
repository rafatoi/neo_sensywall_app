import 'package:flutter/material.dart';
import 'package:neo_sensywall_app/src/app/theme/app_dimensions.dart';

class SensyGridBackground extends StatelessWidget {
  const SensyGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      const Color(0xFFFF1100),
      const Color(0xFF008000),
      const Color(0xFF007BFF),
      const Color(0xFFFFD700),
      const Color(0xFF9C27B0),
      const Color(0xFFFF5722),
      const Color(0xFF00BCD4),
      const Color(0xFFFF1D5E),
      Theme.of(context).colorScheme.primaryContainer,
    ];

    return IgnorePointer(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.space8),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppDimensions.space8,
          crossAxisSpacing: AppDimensions.space8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) => DecoratedBox(
          decoration: BoxDecoration(
            color: colors[index].withValues(alpha: index < 3 ? 0.42 : 0.14),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
      ),
    );
  }
}
