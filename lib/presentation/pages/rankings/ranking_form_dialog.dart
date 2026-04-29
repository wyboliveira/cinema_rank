import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/ranking_provider.dart';

class RankingFormDialog extends ConsumerStatefulWidget {
  const RankingFormDialog({super.key});

  @override
  ConsumerState<RankingFormDialog> createState() => _RankingFormDialogState();
}

class _RankingFormDialogState extends ConsumerState<RankingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _category = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(rankingNotifierProvider.notifier);
    final list = notifier.createNewList(
      title: _title.text.trim(),
      category: _category.text.trim(),
    );
    await notifier.saveList(list);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Lista'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Título obrigatório' : null,
              ),
              const SizedBox(height: AppConstants.kSpacingSmall),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'ex: Terror, 2024, Sci-Fi…',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Categoria obrigatória' : null,
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
        FilledButton(onPressed: _save, child: const Text('Criar')),
      ],
    );
  }
}
