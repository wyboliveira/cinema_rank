import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class ThemeSelectorSection extends ConsumerWidget {
  const ThemeSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider).valueOrNull ?? AppThemeOption.blueCyan;

    return Wrap(
      spacing: AppConstants.kSpacingMedium,
      runSpacing: AppConstants.kSpacingMedium,
      children: AppThemeOption.values.map((option) {
        final isSelected = option == current;
        return _ThemeCard(
          option: option,
          isSelected: isSelected,
          onTap: () => ref.read(themeProvider.notifier).setTheme(option),
        );
      }).toList(),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = option.previewColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.kAnimationNormal,
        width: 140,
        padding: const EdgeInsets.all(AppConstants.kSpacingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: color, radius: 14),
                const SizedBox(width: AppConstants.kSpacingSmall),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 18),
              ],
            ),
            const SizedBox(height: AppConstants.kSpacingSmall),
            Text(
              option.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : null,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
