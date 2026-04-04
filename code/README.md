# Masmorra ASCII — código Dart

Código de apoio ao livro **Masmorra ASCII**: jogo de referência e snapshots por capítulo (`step-01` … `step-37`).

Todo o código fica em **`code/`** na raiz do repositório. O site aponta para os links `tree/main/code/steps/step-NN`.

**Como colaborar:** [CONTRIBUTING.md](../../CONTRIBUTING.md) (raiz do repositório).

## Estrutura

```
.
├── README.md              # este arquivo
├── .gitignore
├── scripts/
│   └── validate_all.sh    # valida steps 01–37 + masmorra_ascii (pub get + analyze --fatal-warnings)
├── masmorra_ascii/        # solução final executável (MUD + masmorra, testes)
└── steps/
    ├── README.md          # índice dos capítulos e tabela dos steps
    ├── step-01/ … step-37/
    └── …                  # guias opcionais (QUICKSTART-*, STEPS-29-36.md, …)
```

| Pasta | Conteúdo |
|--------|----------|
| `masmorra_ascii/` | Jogo completo: `dart lib/main.dart`. É o destino do link "solução final" no site do livro. |
| `steps/step-NN/` | Estado do código ao fim do capítulo NN; ver o `README.md` dentro da pasta e o índice em `steps/README.md`. |

## Requisitos

- [Dart SDK](https://dart.dev/get-dart) (versão compatível com cada `pubspec.yaml`: em geral **3.11+** para `masmorra_ascii` e para os steps recentes).

## Compilar e executar

### Solução final (`masmorra_ascii`)

```bash
cd masmorra_ascii
dart pub get
dart lib/main.dart
dart test
dart analyze --fatal-warnings
```

### Um step isolado

```bash
cd steps/step-01
dart pub get
dart lib/main.dart
```

Consulte o `README.md` do step e o [índice](steps/README.md) para mais detalhes.

### Validar todos os steps e `masmorra_ascii`

A partir desta pasta (`code/` na raiz do repositório):

```bash
./scripts/validate_all.sh
```

Opcional antes de publicar: remover caches locais (não versionados pelo `.gitignore`):

```bash
find . -name .dart_tool -type d -prune -exec rm -rf {} +   # com cuidado
```

## Site Flutter

O site é um repositório **separado** (privado); lê URLs e `site/site_catalog.json` do **repositório público** do livro. Não é necessário Flutter para contribuir aqui.

## Documentação extra

- Índice e tabela de capítulos: [steps/README.md](steps/README.md)
- URLs raw do catálogo e migração de paths: [`../site/RAW_GITHUB_PATHS.md`](../site/RAW_GITHUB_PATHS.md)

## Licença

Código Dart sob licença **MIT** — texto completo em [`LICENSE.md`](../../LICENSE.md) na raiz do repositório.
