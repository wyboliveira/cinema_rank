# ADR-003 — Armazenamento de imagens: arquivo no disco

**Data:** 2026-04-29
**Status:** Aceito

---

## Contexto

O usuário seleciona uma imagem de capa para cada filme. Precisamos decidir
como armazená-la dentro da aplicação Desktop.

## Alternativas consideradas

| Opção | Prós | Contras |
|---|---|---|
| **Caminho no disco (referência)** | Simples; sem cópia; imagens atualizadas automaticamente | Imagem some se o arquivo for movido/deletado |
| Copiar para pasta de dados do app | Portabilidade; imagem nunca some | Consome espaço extra; lógica de cópia necessária |
| BLOB no SQLite | Tudo em um arquivo | Performance ruim para imagens grandes; banco incha |

## Decisão

**Fase inicial:** salvar apenas o caminho absoluto da imagem no campo
`imagePath` do banco. Simples de implementar e adequado para o escopo atual.

**Evolução prevista (ADR futuro):** copiar a imagem para o diretório de dados
do app (`path_provider → getApplicationSupportDirectory`) ao cadastrar, usando
o UUID do filme como nome do arquivo. Isso elimina o problema de arquivo movido.

## Consequências

- O usuário deve manter as imagens nos caminhos originais (limitação da fase atual).
- A exibição usa `Image.file(File(imagePath))` com tratamento de erro para
  arquivo ausente.
- A migração para cópia local será um passo de refatoração documentado.