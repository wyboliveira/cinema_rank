import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/ranking_list.dart';
import '../../providers/ranking_provider.dart';
import 'ranking_detail_page.dart';
import 'ranking_form_dialog.dart';

// Tela de listagem de todos os rankings criados pelo usuário.
class RankingsPage extends ConsumerWidget {
  const RankingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(rankingListsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Listas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const RankingFormDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova Lista'),
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lists) => lists.isEmpty
            ? const _EmptyState()
            : _RankingListView(lists: lists),
      ),
    );
  }
}

class _RankingListView extends ConsumerWidget {
  const _RankingListView({required this.lists});

  final List<RankingList> lists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.kSpacingMedium),
      itemCount: lists.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppConstants.kSpacingSmall),
      itemBuilder: (ctx, i) {
        final list = lists[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.format_list_numbered),
            title: Text(list.title),
            subtitle: Text(list.category),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref
                  .read(rankingNotifierProvider.notifier)
                  .deleteList(list.id),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RankingDetailPage(list: list),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.format_list_numbered,
              size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppConstants.kSpacingMedium),
          Text('Nenhuma lista criada ainda.',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
