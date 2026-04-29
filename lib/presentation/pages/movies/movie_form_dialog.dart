import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/subgenre.dart';
import '../../providers/genre_provider.dart';
import '../../providers/movie_provider.dart';

class MovieFormDialog extends ConsumerStatefulWidget {
  const MovieFormDialog({super.key, this.existingMovie});

  final Movie? existingMovie;

  @override
  ConsumerState<MovieFormDialog> createState() => _MovieFormDialogState();
}

class _MovieFormDialogState extends ConsumerState<MovieFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _year;
  late final TextEditingController _director;
  late final TextEditingController _synopsis;

  String? _imagePath;
  String? _selectedGenreId;
  String? _selectedSubGenreId;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMovie;
    _title = TextEditingController(text: m?.title ?? '');
    _year = TextEditingController(text: m?.year.toString() ?? '');
    _director = TextEditingController(text: m?.director ?? '');
    _synopsis = TextEditingController(text: m?.synopsis ?? '');
    _imagePath = m?.imagePath;
    _selectedGenreId = m?.genreId;
    _selectedSubGenreId = m?.subGenreId;
  }

  @override
  void dispose() {
    _title.dispose();
    _year.dispose();
    _director.dispose();
    _synopsis.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _imagePath = result.files.single.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(movieNotifierProvider.notifier);
    final existing = widget.existingMovie;

    final movie = existing != null
        ? existing.copyWith(
            title: _title.text.trim(),
            year: int.parse(_year.text.trim()),
            director: _director.text.trim(),
            synopsis: _synopsis.text.trim(),
            imagePath: _imagePath,
            genreId: _selectedGenreId,
            subGenreId: _selectedSubGenreId,
          )
        : notifier.createNew(
            title: _title.text.trim(),
            year: int.parse(_year.text.trim()),
            director: _director.text.trim(),
            synopsis: _synopsis.text.trim(),
            imagePath: _imagePath,
            genreId: _selectedGenreId,
            subGenreId: _selectedSubGenreId,
          );

    await notifier.save(movie);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMovie != null;
    final genresAsync = ref.watch(genresStreamProvider);
    final subgenresAsync = _selectedGenreId != null
        ? ref.watch(subgenresStreamProvider(_selectedGenreId!))
        : const AsyncData(<Subgenre>[]);

    final genres = genresAsync.valueOrNull ?? <Genre>[];
    final subgenres = subgenresAsync.valueOrNull ?? <Subgenre>[];

    return AlertDialog(
      title: Text(isEdit ? 'Editar Filme' : 'Novo Filme'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Coluna esquerda: campos de texto ──────────────────────
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Linha 1: Título
                      _field(_title, 'Título', required: true),
                      const SizedBox(height: AppConstants.kSpacingSmall),
                      // Linha 2: Gênero + Subgênero
                      Row(
                        children: [
                          Expanded(
                            child: _GenreDropdown(
                              genres: genres,
                              selectedId: _selectedGenreId,
                              onChanged: (id) => setState(() {
                                _selectedGenreId = id;
                                // Reseta subgênero quando o gênero muda.
                                _selectedSubGenreId = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: AppConstants.kSpacingSmall),
                          Expanded(
                            child: _SubgenreDropdown(
                              subgenres: subgenres,
                              selectedId: _selectedSubGenreId,
                              enabled: _selectedGenreId != null,
                              onChanged: (id) =>
                                  setState(() => _selectedSubGenreId = id),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.kSpacingSmall),
                      // Linha 3: Sinopse (ocupa o espaço restante)
                      Expanded(
                        child: TextFormField(
                          controller: _synopsis,
                          decoration: const InputDecoration(
                            labelText: 'Sinopse',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: null,
                          expands: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.kSpacingMedium),
                // ── Coluna direita: ano, diretor e imagem ─────────────────
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Linha 1: Ano
                      _field(_year, 'Ano', required: true, isNumeric: true),
                      const SizedBox(height: AppConstants.kSpacingSmall),
                      // Linha 2: Diretor
                      _field(_director, 'Diretor', required: true),
                      const SizedBox(height: AppConstants.kSpacingSmall),
                      // Linha 3: Seleção de imagem
                      Expanded(child: _ImagePicker(
                        imagePath: _imagePath,
                        onPick: _pickImage,
                        onClear: () => setState(() => _imagePath = null),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumeric ? TextInputType.number : null,
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return '$label é obrigatório';
              if (isNumeric && int.tryParse(v.trim()) == null) {
                return 'Número inválido';
              }
              return null;
            }
          : null,
    );
  }
}

// ── Dropdown de Gênero ────────────────────────────────────────────────────────
class _GenreDropdown extends StatelessWidget {
  const _GenreDropdown({
    required this.genres,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Genre> genres;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      decoration: const InputDecoration(
        labelText: 'Gênero',
        border: OutlineInputBorder(),
      ),
      hint: const Text('Não selecionado'),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Não selecionado'),
        ),
        ...genres.map(
          (g) => DropdownMenuItem<String>(value: g.id, child: Text(g.name)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

// ── Dropdown de Subgênero ─────────────────────────────────────────────────────
class _SubgenreDropdown extends StatelessWidget {
  const _SubgenreDropdown({
    required this.subgenres,
    required this.selectedId,
    required this.enabled,
    required this.onChanged,
  });

  final List<Subgenre> subgenres;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Garante que selectedId seja válido para a lista atual antes de renderizar.
    final validId = subgenres.any((s) => s.id == selectedId) ? selectedId : null;

    return DropdownButtonFormField<String>(
      initialValue: validId,
      decoration: const InputDecoration(
        labelText: 'Subgênero',
        border: OutlineInputBorder(),
      ),
      hint: Text(enabled ? 'Não selecionado' : 'Selecione um gênero'),
      isExpanded: true,
      items: enabled
          ? [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Não selecionado'),
              ),
              ...subgenres.map(
                (s) =>
                    DropdownMenuItem<String>(value: s.id, child: Text(s.name)),
              ),
            ]
          : [],
      onChanged: enabled ? onChanged : null,
    );
  }
}

// ── Área de seleção de imagem ─────────────────────────────────────────────────
class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.imagePath,
    required this.onPick,
    required this.onClear,
  });

  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kCardBorderRadius),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton.filled(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: onClear,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(28, 28),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Selecionar imagem'),
                ),
                const SizedBox(height: AppConstants.kSpacingSmall),
                Text(
                  'ou',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Colar  Ctrl + V',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
