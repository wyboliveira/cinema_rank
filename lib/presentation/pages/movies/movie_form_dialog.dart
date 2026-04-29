import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';

// Formulário de cadastro/edição de filme apresentado como dialog.
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
  late final TextEditingController _genre;
  late final TextEditingController _director;
  late final TextEditingController _synopsis;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMovie;
    _title = TextEditingController(text: m?.title ?? '');
    _year = TextEditingController(text: m?.year.toString() ?? '');
    _genre = TextEditingController(text: m?.genre ?? '');
    _director = TextEditingController(text: m?.director ?? '');
    _synopsis = TextEditingController(text: m?.synopsis ?? '');
    _imagePath = m?.imagePath;
  }

  @override
  void dispose() {
    _title.dispose();
    _year.dispose();
    _genre.dispose();
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
            genre: _genre.text.trim(),
            director: _director.text.trim(),
            synopsis: _synopsis.text.trim(),
            imagePath: _imagePath,
          )
        : notifier.createNew(
            title: _title.text.trim(),
            year: int.parse(_year.text.trim()),
            genre: _genre.text.trim(),
            director: _director.text.trim(),
            synopsis: _synopsis.text.trim(),
            imagePath: _imagePath,
          );

    await notifier.save(movie);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMovie != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar Filme' : 'Novo Filme'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(_title, 'Título', required: true),
                const SizedBox(height: AppConstants.kSpacingSmall),
                _field(_year, 'Ano', required: true, isNumeric: true),
                const SizedBox(height: AppConstants.kSpacingSmall),
                _field(_genre, 'Gênero', required: true),
                const SizedBox(height: AppConstants.kSpacingSmall),
                _field(_director, 'Diretor', required: true),
                const SizedBox(height: AppConstants.kSpacingSmall),
                _field(_synopsis, 'Sinopse', maxLines: 3),
                const SizedBox(height: AppConstants.kSpacingMedium),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(_imagePath == null
                      ? 'Selecionar imagem'
                      : 'Imagem selecionada'),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : null,
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return '$label é obrigatório';
              if (isNumeric && int.tryParse(v.trim()) == null) {
                return 'Digite um número válido';
              }
              return null;
            }
          : null,
    );
  }
}
