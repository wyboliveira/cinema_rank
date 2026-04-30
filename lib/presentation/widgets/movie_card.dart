import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/movie.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.genreLabel,
    this.onTap,
    this.trailing,
  });

  final Movie movie;
  final String? genreLabel; // ex: "Ação · Espionagem" — calculado no parent
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingMedium),
          child: Row(
            children: [
              MoviePoster(imagePath: movie.imagePath),
              const SizedBox(width: AppConstants.kSpacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [movie.year.toString(), ?genreLabel].join(' · '),
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      movie.director,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppConstants.kAnimationNormal);
  }
}

// Widget de poster reutilizável nos 3 modos de exibição.
class MoviePoster extends StatelessWidget {
  const MoviePoster({
    super.key,
    this.imagePath,
    this.width = AppConstants.kMovieImageWidth,
    this.height = AppConstants.kMovieImageHeight,
    this.borderRadius = 6,
  });

  final String? imagePath;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: imagePath != null && File(imagePath!).existsSync()
            ? Image.file(File(imagePath!), fit: BoxFit.cover)
            : ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.movie, size: 32),
              ),
      ),
    );
  }
}
