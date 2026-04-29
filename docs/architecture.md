# Arquitetura — cinema_rank

## Visão geral

O projeto adota **Clean Architecture** adaptada para Flutter Desktop, com quatro
camadas bem definidas e uma regra de dependência unidirecional.

---

## Diagrama de camadas

```
┌─────────────────────────────────────────────────────────┐
│                     presentation/                        │
│   pages · widgets · providers (Riverpod)                │
└────────────────────────┬────────────────────────────────┘
                         │ consome
┌────────────────────────▼────────────────────────────────┐
│                       domain/                            │
│   entities · repository interfaces (abstratos)          │
└───────────┬────────────────────────────┬────────────────┘
            │ implementado por           │ usado por
┌───────────▼──────────┐     ┌──────────▼────────────────┐
│        data/          │     │          core/             │
│  database · models    │     │  logger · tema · rotas     │
│  repository impls     │     │  constantes · extensões    │
└──────────────────────┘     └───────────────────────────┘
```

### Regra de dependência

- `domain` é o núcleo: **não depende de nada** além do Dart puro.
- `data` depende de `domain` (implementa suas interfaces) e de libs externas
  (Drift, path_provider).
- `presentation` depende de `domain` (via providers) e de `core`.
- `core` não depende de nenhuma outra camada do projeto.

---

## Camadas em detalhe

### core/

Infraestrutura transversal disponível para todas as camadas.

| Módulo | Responsabilidade |
|---|---|
| `constants/app_constants.dart` | Tamanhos, durações de animação, strings fixas |
| `theme/app_theme.dart` | Tema Material 3, paleta de cores, estilos de texto |
| `router/app_router.dart` | Definição de rotas nomeadas |
| `utils/logger.dart` | Singleton `AppLogger` que envolve o pacote `logger` |

### domain/

Regras de negócio puras. Zero dependências de frameworks.

**Entidades** (`domain/entities/`):

```
Movie
  id, title, year, genre, director, synopsis, imagePath, createdAt

RankingList
  id, title, category, createdAt

RankingItem
  id, listId, movieId, position
```

**Repositórios abstratos** (`domain/repositories/`):

```dart
abstract class MovieRepository {
  Future<List<Movie>> getAll();
  Future<Movie?> getById(String id);
  Future<void> save(Movie movie);
  Future<void> delete(String id);
  Stream<List<Movie>> watchAll();
}

abstract class RankingListRepository {
  Future<List<RankingList>> getAll();
  Future<void> save(RankingList list);
  Future<void> delete(String id);
  Future<void> reorderItems(String listId, List<RankingItem> items);
  Stream<List<RankingItem>> watchItemsByList(String listId);
}
```

### data/

Implementações concretas dos repositórios, schema do banco e modelos.

**Banco de dados** (`data/database/`):
- `AppDatabase` — classe principal Drift com `schemaVersion` e `migration`.
- `MoviesTable` — tabela de filmes.
- `RankingListsTable` — tabela de listas.
- `RankingItemsTable` — tabela de itens (FK para as duas acima).
- `daos/` — um DAO por entidade, com queries otimizadas.

**Modelos** (`data/models/`):
- Extensões de conversão: `MovieModel.toEntity()` / `Movie.toModel()`.

**Repositórios** (`data/repositories/`):
- `MovieRepositoryImpl` implementa `MovieRepository` via DAOs.
- `RankingListRepositoryImpl` implementa `RankingListRepository`.

### presentation/

UI e estado de tela. Nunca contém regras de negócio.

**Providers** (`presentation/providers/`):
- Gerados via `@riverpod` annotation + build_runner.
- Injetam implementações de repositório; expõem `AsyncValue<T>` para a UI.

**Pages** (`presentation/pages/`):
- `home/` — tela inicial com atalhos para biblioteca e listas.
- `movies/` — lista de filmes cadastrados + formulário de cadastro.
- `rankings/` — lista de rankings + tela de ranking individual com drag-and-drop.

**Widgets** (`presentation/widgets/`):
- `MovieCard` — card de filme reutilizável.
- `RankingItemTile` — tile arrastável de item de ranking.
- `ImagePickerField` — campo de seleção de imagem com preview.

---

## Fluxo de dados

```
Usuário
  │ interage com
  ▼
Widget (ConsumerWidget)
  │ lê/invoca
  ▼
Provider (Riverpod AsyncNotifier)
  │ chama método de
  ▼
Repository (interface domain/)
  │ implementado por
  ▼
RepositoryImpl (data/)
  │ usa
  ▼
DAO (Drift)
  │ executa
  ▼
SQLite (arquivo local no disco)
```

---

## Drag-and-drop e animações

O reordenamento de itens utiliza o widget nativo `ReorderableListView` do
Flutter, complementado com animações de `flutter_animate` para:
- Escala no início do drag (item "cresce" levemente).
- Sombra elevada durante o arrasto.
- Transição suave ao soltar o item na nova posição.

A posição final é persistida chamando `RankingListRepository.reorderItems()`,
que atualiza o campo `position` de todos os itens afetados em uma única
transação SQLite.

---

## Decisões de arquitetura

Veja os ADRs individuais em [adr/](adr/).

| ADR | Decisão |
|---|---|
| [ADR-001](adr/001-banco-de-dados.md) | Drift (SQLite) como banco de dados local |
| [ADR-002](adr/002-estado-riverpod.md) | Riverpod 2 como gerenciador de estado |
| [ADR-003](adr/003-imagens-disco.md) | Imagens armazenadas no disco (caminho no banco) |
| [ADR-004](adr/004-drag-drop.md) | ReorderableListView + flutter_animate para drag-and-drop |