# ADR-001 — Banco de dados: Drift (SQLite)

**Data:** 2026-04-29
**Status:** Aceito

---

## Contexto

O cinema_rank precisa de persistência local para filmes, listas e rankings.
A aplicação roda exclusivamente no Windows Desktop, sem servidor.

## Alternativas consideradas

| Opção | Prós | Contras |
|---|---|---|
| **Drift (SQLite)** | Type-safe, suporte Windows, streams reativos, migrações versionadas | Requer build_runner |
| `sqflite` | Mais simples | **Não suporta Windows Desktop** |
| Hive | Rápido, sem build_runner | NoSQL: relações entre entidades são manuais |
| `shared_preferences` | Simples | Só para prefs simples; inadequado para dados relacionais |

## Decisão

**Drift** com `sqlite3_flutter_libs` (driver nativo Windows).

## Consequências

- É necessário rodar `dart run build_runner build` após alterações no schema.
- Migrações devem ser versionadas (`schemaVersion`) para não perder dados do usuário.
- As queries são verificadas em tempo de compilação — erros de SQL aparecem no `flutter analyze`.