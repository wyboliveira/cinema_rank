import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
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

  // Tenta colar imagem da área de transferência.
  // Ordem de preferência: PNG → JPEG → GIF → WebP → BMP → URI de arquivo.
  Future<void> _tryPasteImage() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final reader = await clipboard.read();

    // Formatos binários de imagem (dados brutos na clipboard)
    final imageFormats = <(FileFormat, String)>[
      (Formats.png, 'png'),
      (Formats.jpeg, 'jpg'),
      (Formats.gif, 'gif'),
      (Formats.webp, 'webp'),
      (Formats.bmp, 'bmp'),
      (Formats.tiff, 'tiff'),
    ];

    for (final (format, ext) in imageFormats) {
      if (reader.canProvide(format)) {
        reader.getFile(format, (file) async {
          final bytes = await file.readAll();
          final savedPath = await _savePastedImage(bytes, ext);
          if (mounted) setState(() => _imagePath = savedPath);
        });
        return;
      }
    }

    // Fallback: URI de arquivo (imagem copiada no Explorer com Ctrl+C)
    if (reader.canProvide(Formats.fileUri)) {
      final uri = await reader.readValue(Formats.fileUri);
      if (uri != null) {
        final filePath = uri.toFilePath();
        if (_isImagePath(filePath) && mounted) {
          setState(() => _imagePath = filePath);
        }
      }
    }
  }

  Future<String> _savePastedImage(Uint8List bytes, String ext) async {
    final dir = await getApplicationSupportDirectory();
    final imagesDir = Directory(p.join(dir.path, 'pasted_images'));
    await imagesDir.create(recursive: true);
    final filePath = p.join(imagesDir.path, '${const Uuid().v4()}.$ext');
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }

  bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tiff']
        .any(lower.endsWith);
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
    // Dispara validação visual (bordas vermelhas) sem depender do resultado —
    // Form.currentState pode ser null em edge cases de layout.
    _formKey.currentState?.validate();

    if (!_validateControllers()) {
      _showDialog('Preencha todos os campos obrigatórios: Título, Ano e Diretor.');
      return;
    }

    try {
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
    } catch (e, st) {
      AppLogger.error('Erro ao salvar filme', e, st);
      _showDialog('Erro ao salvar: $e');
    }
  }

  // Validação autoritativa pelos controllers — não depende do Form/GlobalKey.
  bool _validateControllers() {
    final year = int.tryParse(_year.text.trim());
    return _title.text.trim().isNotEmpty &&
        year != null &&
        _director.text.trim().isNotEmpty;
  }

  // Usa showDialog (Navigator) em vez de SnackBar para garantir visibilidade
  // independente de haver ScaffoldMessenger no contexto do dialog.
  void _showDialog(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aviso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMovie != null;
    final genres = ref.watch(genresStreamProvider).valueOrNull ?? <Genre>[];
    final subgenres = _selectedGenreId != null
        ? ref.watch(subgenresStreamProvider(_selectedGenreId!)).valueOrNull ??
            <Subgenre>[]
        : <Subgenre>[];

    // Focus intercepta Ctrl+V globalmente no dialog para colar imagens.
    // KeyEventResult.ignored garante que campos de texto continuem recebendo
    // o evento e possam colar texto normalmente pelo seu próprio handler.
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyV &&
            HardwareKeyboard.instance.isControlPressed) {
          _tryPasteImage();
        }
        return KeyEventResult.ignored;
      },
      child: AlertDialog(
        title: Text(isEdit ? 'Editar Filme' : 'Novo Filme'),
      // 📖 Sem altura fixa no SizedBox externo: erros de validação adicionam
      // altura aos campos e o dialog se expande sem quebrar o layout.
      // Synopsis e ImagePicker têm suas próprias alturas fixas via SizedBox
      // interno — expands:true funciona porque recebe height finita do pai
      // imediato, sem depender do Column ter altura finita.
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Coluna esquerda: Título / Gêneros / Sinopse ───────────────
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _field(_title, 'Título', required: true),
                    const SizedBox(height: AppConstants.kSpacingSmall),
                    Row(
                      children: [
                        Expanded(
                          child: _GenreDropdown(
                            genres: genres,
                            selectedId: _selectedGenreId,
                            onChanged: (id) => setState(() {
                              _selectedGenreId = id;
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
                    SizedBox(
                      height: 130,
                      child: TextFormField(
                        controller: _synopsis,
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          labelText: 'Sinopse',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.kSpacingMedium),
              // ── Coluna direita: Ano / Diretor / Imagem ────────────────────
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _field(
                      _year,
                      'Ano',
                      required: true,
                      isNumeric: true,
                    ),
                    const SizedBox(height: AppConstants.kSpacingSmall),
                    _field(_director, 'Diretor', required: true),
                    const SizedBox(height: AppConstants.kSpacingSmall),
                    SizedBox(
                      height: 140,
                      child: _ImagePickerArea(
                        imagePath: _imagePath,
                        onPick: _pickImage,
                        onPaste: _tryPasteImage,
                        onClear: () => setState(() => _imagePath = null),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      ),
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
      inputFormatters:
          isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
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
    // Garante que o value exibido pertença à lista atual.
    final validId =
        genres.any((g) => g.id == selectedId) ? selectedId : null;

    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: validId,
      decoration: const InputDecoration(
        labelText: 'Gênero',
        border: OutlineInputBorder(),
      ),
      hint: const Text('Não selecionado'),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('— Nenhum —')),
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
    final validId =
        subgenres.any((s) => s.id == selectedId) ? selectedId : null;

    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: validId,
      decoration: const InputDecoration(
        labelText: 'Subgênero',
        border: OutlineInputBorder(),
      ),
      hint: Text(enabled ? '— Nenhum —' : 'Selecione um gênero'),
      isExpanded: true,
      items: enabled
          ? [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('— Nenhum —'),
              ),
              ...subgenres.map(
                (s) => DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(s.name),
                ),
              ),
            ]
          : [],
      onChanged: enabled ? onChanged : null,
    );
  }
}

// ── Área de seleção de imagem ─────────────────────────────────────────────────
class _ImagePickerArea extends StatelessWidget {
  const _ImagePickerArea({
    required this.imagePath,
    required this.onPick,
    required this.onPaste,
    required this.onClear,
  });

  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onPaste;
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
                  borderRadius: BorderRadius.circular(
                    AppConstants.kCardBorderRadius,
                  ),
                  child: Image.file(File(imagePath!), fit: BoxFit.cover),
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
                GestureDetector(
                  onTap: onPaste,
                  child: Text(
                    'Colar  Ctrl + V',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
