# cinema_rank

Sistema interativo de ranking de filmes construído com **Flutter Desktop (Windows)**.

> Projeto build-to-learn: o código é escrito com foco didático, incluindo
> comentários explicativos, logs estruturados e documentação de decisões técnicas.

---

## Funcionalidades

- **Cadastro de filmes** — título, ano, gênero, diretor, sinopse e imagem local.
- **Biblioteca** — visualize e pesquise todos os filmes cadastrados.
- **Listas de ranking** — crie listas temáticas com título e categoria livres.
- **Drag-and-drop** — ordene filmes na lista arrastando com animações fluidas.
- **Persistência local** — banco SQLite embutido, sem necessidade de servidor.

---

## Stack

| Tecnologia | Uso |
|---|---|
| Flutter 3.41+ | UI e runtime Desktop Windows |
| Dart 3.11+ | Linguagem |
| Riverpod 2 | Gerenciamento de estado |
| Drift (SQLite) | Banco de dados local type-safe |
| flutter_animate | Animações de drag-and-drop |
| file_picker | Seleção de imagem do disco |
| logger | Logs estruturados |

---

## Arquitetura

Clean Architecture em três camadas:

```
domain ← data
  ↑
presentation
  ↑
core (transversal)
```

Consulte [docs/architecture.md](docs/architecture.md) para detalhes.

---

## Pré-requisitos

- Windows 10/11 64-bit
- Flutter SDK 3.41+
- Visual Studio 2022 com workload **"Desktop development with C++"**

---

## Como executar

```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar código (Drift + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 3. Executar
flutter run -d windows
```

---

## Estrutura de diretórios

```
cinema_rank/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/          # Utilitários transversais (logger, tema, rotas)
│   ├── data/          # Banco de dados, modelos, repositórios concretos
│   ├── domain/        # Entidades e contratos (sem dependências externas)
│   └── presentation/  # Telas, widgets, providers Riverpod
├── assets/
│   ├── images/
│   └── fonts/
├── docs/              # Documentação técnica e ADRs
├── test/
├── CLAUDE.md          # Normas para desenvolvimento com IA
└── pubspec.yaml
```

---

## Documentação técnica

| Documento | Descrição |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Normas de código, padrões e arquitetura para o assistente IA |
| [docs/architecture.md](docs/architecture.md) | Visão geral da arquitetura em camadas |
| [docs/adr/](docs/adr/) | Registros de decisão de arquitetura (ADRs) |

---

## Licença

Projeto pessoal / educacional. Sem licença comercial.
