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

**Estratégia híbrida (implementada):**

- **Seleção via file_picker:** salva apenas o caminho absoluto da imagem no
  campo `imagePath`. Simples; depende do arquivo permanecer no local original.

- **Cole via Ctrl+V (super_clipboard):** os bytes da imagem são copiados
  imediatamente para `getApplicationSupportDirectory()/pasted_images/<uuid>.<ext>`.
  A imagem colada é permanente e portável — não depende da fonte original.

Esta abordagem híbrida foi motivada pela necessidade técnica: imagens da
clipboard chegam como dados binários em memória, sem caminho de arquivo, então
a cópia para disco é inevitável. Ao fazer isso apenas para imagens coladas,
preserva-se a simplicidade para o caso de seleção de arquivo.

## Consequências

- Imagens selecionadas via file_picker podem ser perdidas se o arquivo for movido.
- Imagens coladas via Ctrl+V são armazenadas em `AppSupportDir/pasted_images/` e nunca se perdem.
- A exibição usa `Image.file(File(imagePath))` com fallback para `Icon(Icons.movie)` se o arquivo não existir.
- Uma futura refatoração pode unificar as duas estratégias copiando sempre para `AppSupportDir`.