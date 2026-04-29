# ADR-002 — Gerenciamento de estado: Riverpod 2

**Data:** 2026-04-29
**Status:** Aceito

---

## Contexto

A aplicação tem estado assíncrono (leituras do banco), estado derivado (lista
filtrada de filmes) e mutações (cadastro, reordenação). Precisamos de uma
solução previsível, testável e compatível com Flutter Desktop.

## Alternativas consideradas

| Opção | Prós | Contras |
|---|---|---|
| **Riverpod 2** | Type-safe, sem BuildContext, testável, `AsyncValue` nativo | Curva de aprendizado inicial |
| Provider | Simples, popular | Depende de BuildContext; Riverpod é sua evolução direta |
| BLoC | Separação clara | Verbose; boilerplate alto para um projeto solo |
| setState | Zero dependência | Não escala; estado local apenas |

## Decisão

**Riverpod 2** com `riverpod_annotation` e `riverpod_generator` para geração
de código via `build_runner`. Providers do tipo `AsyncNotifier` para dados
assíncronos, `Notifier` para estado síncrono.

## Consequências

- Providers são gerados automaticamente — evita boilerplate manual.
- `AsyncValue<T>` elimina if/else de loading/error/data nos widgets.
- Testes de providers não requerem `WidgetTester` — podem ser testes unitários puros.
- Requer `build_runner` junto ao Drift (já no projeto).