# CLAUDE.md — cinema_rank

Guia de referência para o assistente de IA (Claude Code) e para desenvolvedores
que trabalham neste repositório. Leia este arquivo antes de qualquer tarefa de
código.

---

## 1. Visão geral do projeto

**cinema_rank** é uma aplicação Flutter Desktop (Windows) para cadastro e
ranking interativo de filmes. O usuário cadastra filmes, cria listas temáticas e
ordena os filmes por meio de drag-and-drop com feedback visual animado.

Objetivo secundário: **build-to-learn** — o projeto deve ser didático, com
comentários explicativos nos pontos não óbvios, logs descritivos e documentação
de decisões técnicas.

---

## 2. Stack tecnológica

| Camada | Tecnologia | Motivo |
|---|---|---|
| UI | Flutter 3.41+ (Windows Desktop) | Target principal da aplicação |
| Linguagem | Dart 3.11+ | Linguagem nativa do Flutter |
| Estado | Riverpod 2 + riverpod_annotation | Reativo, type-safe, testável |
| Banco de dados | Drift + SQLite | ORM type-safe, suporte nativo Windows |
| Imagens | file_picker | Seleção de arquivo local no Desktop |
| Animações | flutter_animate | DSL declarativa leve |
| Tipografia | google_fonts | Consistência visual |
| Logging | logger | Logs estruturados com níveis |
| IDs | uuid v4 | Identificadores únicos sem dependência de DB |

---

## 3. Arquitetura — Clean Architecture

```
lib/
├── main.dart                   # Ponto de entrada, injeção do ProviderScope
├── app.dart                    # MaterialApp, tema, rotas
│
├── core/                       # Infraestrutura transversal (sem regras de negócio)
│   ├── constants/              # Constantes da aplicação (cores, tamanhos, strings)
│   ├── theme/                  # AppTheme, paleta de cores, estilos de texto
│   ├── router/                 # Rotas nomeadas (GoRouter ou Navigator 2)
│   └── utils/                  # Logger singleton, formatadores, extensões
│
├── data/                       # Acesso a dados (implementações concretas)
│   ├── database/               # Schema Drift, AppDatabase, migrações
│   │   └── daos/               # Data Access Objects por entidade
│   ├── models/                 # Modelos de dados (tabelas Drift, JSON)
│   └── repositories/           # Implementações dos contratos do domain
│
├── domain/                     # Regras de negócio puras (sem Flutter, sem Drift)
│   ├── entities/               # Entidades imutáveis (Movie, RankingList, RankingItem)
│   └── repositories/           # Contratos abstratos (interfaces)
│
└── presentation/               # UI e estado de tela
    ├── pages/                  # Telas completas (home, movies, rankings)
    ├── widgets/                # Widgets reutilizáveis
    └── providers/              # Riverpod providers (gerados via annotation)
```

### Regra de dependência

```
presentation → domain ← data
                ↑
              core (todos podem usar)
```

- `domain` nunca importa `data`, `presentation` ou Flutter SDK.
- `data` implementa interfaces de `domain`.
- `presentation` consome providers que injetam repositórios de `data`.

---

## 4. Entidades principais

### Movie
| Campo | Tipo | Descrição |
|---|---|---|
| id | String (UUID) | Identificador único |
| title | String | Título do filme |
| year | int | Ano de lançamento |
| genre | String | Gênero principal |
| director | String | Diretor |
| synopsis | String | Sinopse curta |
| imagePath | String? | Caminho absoluto da imagem no disco |
| createdAt | DateTime | Data de cadastro |

### RankingList
| Campo | Tipo | Descrição |
|---|---|---|
| id | String (UUID) | Identificador único |
| title | String | Título da lista |
| category | String | Categoria livre (ex: "Terror", "2024") |
| createdAt | DateTime | Data de criação |

### RankingItem
| Campo | Tipo | Descrição |
|---|---|---|
| id | String (UUID) | Identificador único |
| listId | String | FK → RankingList |
| movieId | String | FK → Movie |
| position | int | Posição na lista (1-based) |

---

## 5. Padrões de código

### 5.1 Nomenclatura

| Artefato | Convenção | Exemplo |
|---|---|---|
| Classes | PascalCase | `MovieRepository` |
| Funções / variáveis | camelCase | `fetchAllMovies` |
| Constantes | camelCase (ou SCREAMING_SNAKE em `constants/`) | `kCardBorderRadius` |
| Arquivos | snake_case | `movie_repository_impl.dart` |
| Testes | `<arquivo>_test.dart` | `movie_repository_impl_test.dart` |

### 5.2 Comentários

- Comente o **POR QUÊ**, nunca o **O QUÊ** (o código já diz o quê).
- Para blocos didáticos (build-to-learn), use o prefixo `// 📖` para marcar
  explicações educacionais que podem ser removidas em produção.
- Máximo de uma linha por comentário inline. Para contexto maior, use bloco
  `///` apenas em APIs públicas de `domain/`.

```dart
// ✅ Bom — explica decisão não óbvia
// Usamos position 1-based para facilitar a exibição ao usuário sem conversão.
final position = items.length + 1;

// ❌ Ruim — descreve o que o código já mostra
// Incrementa position em 1
final position = items.length + 1;

// 📖 (didático) Drift gera SQL puro em tempo de compilação; zero reflection.
@DriftDatabase(tables: [Movies, RankingLists, RankingItems])
class AppDatabase extends _$AppDatabase { ... }
```

### 5.3 Logging

Use o singleton `AppLogger` (em `core/utils/logger.dart`) em vez de `print`.

```dart
AppLogger.info('Filme cadastrado', {'id': movie.id, 'title': movie.title});
AppLogger.warning('Imagem não encontrada no caminho', {'path': imagePath});
AppLogger.error('Falha ao salvar lista', error, stackTrace);
```

Níveis:
- `debug` — fluxo interno, iterações, valores intermediários.
- `info` — ações do usuário, operações concluídas com sucesso.
- `warning` — situação inesperada mas recuperável.
- `error` — falha que impede a operação; sempre passe o `StackTrace`.

### 5.4 Providers (Riverpod)

- Um arquivo por provider, localizado em `presentation/providers/`.
- Use `@riverpod` annotation + `build_runner` para geração de código.
- Providers de estado mutável usam `@riverpod class` (AsyncNotifier ou Notifier).
- Nunca acesse o banco diretamente na camada de presentation — passe sempre
  pelo repositório injetado no provider.

### 5.5 Widgets

- Extraia widgets com mais de 60 linhas para arquivos próprios em `widgets/`.
- Prefira `StatelessWidget` + Riverpod `ConsumerWidget` a `StatefulWidget`.
- Use `const` em todos os widgets que não dependem de estado.

---

## 6. Banco de dados e migrações

- O schema é definido em `data/database/app_database.dart`.
- A cada alteração de schema, incremente `schemaVersion` e adicione um passo
  em `migration`.
- Nunca apague uma coluna em produção sem um passo de migração.
- Execute `dart run build_runner build` após modificar tabelas Drift.

---

## 7. Fluxo de desenvolvimento

```
1. Criar branch: feat/<feature> | fix/<bug> | docs/<doc>
2. Codificar seguindo as normas desta seção 5
3. Executar: flutter analyze && flutter test
4. Commit semântico: feat|fix|docs|refactor|test|chore: <descrição em pt-BR>
5. Push e PR para main
```

### Commits semânticos (em português)

```
feat: adiciona tela de cadastro de filmes
fix: corrige ordenação de itens ao reordenar lista
docs: atualiza diagrama de arquitetura
refactor: extrai lógica de posicionamento para RankingService
test: adiciona testes unitários para MovieRepository
chore: atualiza dependências para versões estáveis
```

---

## 8. Geração de código

```bash
# Gera DAOs do Drift e providers do Riverpod
dart run build_runner build --delete-conflicting-outputs

# Modo watch (desenvolvimento contínuo)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 9. Comandos frequentes

```bash
flutter run -d windows          # Executa no Desktop Windows
flutter analyze                 # Análise estática
flutter test                    # Testes unitários e de widget
flutter build windows           # Build de produção
```

---

## 10. O que NÃO fazer

- Não use `print()` — use `AppLogger`.
- Não importe `drift` na camada `domain/`.
- Não coloque lógica de negócio em widgets ou providers.
- Não comite arquivos gerados (`*.g.dart`) — o `.gitignore` já os exclui.
- Não altere o schema do banco sem adicionar migração.
- Não use `dynamic` ou `var` sem necessidade — prefira tipos explícitos.