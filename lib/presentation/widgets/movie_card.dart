import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/movie.dart';

// Card reutilizável de filme. Aparece na biblioteca e nos dialogs de seleção.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, this.onTap, this.trailing});

  final Movie movie;
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
              _Poster(imagePath: movie.imagePath),
              const SizedBox(width: AppConstants.kSpacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${movie.year} · ${movie.genre}',
                        style: theme.textTheme.bodySmall),
                    Text(movie.director,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
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

class _Poster extends StatelessWidget {
  const _Poster({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: AppConstants.kMovieImageWidth,
        height: AppConstants.kMovieImageHeight,
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
