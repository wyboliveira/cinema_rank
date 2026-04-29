# ADR-004 — Drag-and-drop: ReorderableListView + flutter_animate

**Data:** 2026-04-29
**Status:** Aceito

---

## Contexto

O diferencial da aplicação é a mecânica de reordenação de filmes em uma lista
de ranking. A UX deve ser fluida, leve e visualmente agradável.

## Alternativas consideradas

| Opção | Prós | Contras |
|---|---|---|
| **ReorderableListView (Flutter nativo)** | Zero dependência extra; mantido pelo time Flutter | Customização de feedback limitada |
| `flutter_reorderable_list` (pub.dev) | Mais controle visual | Pacote menos ativo |
| Implementação manual com Draggable/DragTarget | Controle total | Alta complexidade; difícil de manter |

## Decisão

`ReorderableListView` nativo do Flutter para a lógica de reordenação, com
`flutter_animate` para adicionar feedback visual:

- **Escala** ao iniciar o drag (`scale: 1.05`).
- **Elevação/sombra** durante o arrasto.
- **Fade + slide** ao reposicionar o item.

O callback `onReorder` atualiza o campo `position` de todos os itens da lista
em uma única transação Drift.

## Consequências

- `ReorderableListView` exige que cada filho tenha uma `Key` única — usaremos
  o `id` (UUID) da entidade `RankingItem`.
- A persistência da ordem usa transação atômica: ou todos os `position` são
  atualizados ou nenhum (garantia de consistência).
- `flutter_animate` já está no `pubspec.yaml` — sem dependência extra.