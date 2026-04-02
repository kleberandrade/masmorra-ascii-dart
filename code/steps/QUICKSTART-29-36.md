# Guia rápido — Steps 29–36

Todos os comandos assumem que estás na pasta `steps/` dentro de `code/` (raiz do repositório), ou ajusta os `cd` em conformidade.

## Solução final jogável

O jogo completo de referência **não** está em `step-36`. Usa o pacote irmão:

```bash
cd ../masmorra_ascii
dart pub get
dart lib/main.dart
dart test
```

## Steps 29–31 (entrada e organização)

```bash
cd step-29
dart pub get
dart lib/main.dart   # se existir; senão: dart test
dart test

cd ../step-30
dart pub get
dart lib/main.dart
dart test

cd ../step-31
dart pub get
dart lib/main.dart
dart analyze
```

## Steps 32–35 (fragmentos evolutivos)

Cada pasta pode ter só parte do código (arquivos de exemplo dos capítulos 32–35). Usa `dart pub get`, `dart test` e `dart analyze` dentro da pasta. Se `lib/main.dart` existir, `dart lib/main.dart`; caso contrário, foca em testes e análise estática.

## Qualidade

```bash
dart analyze
dart format .
```

## Documentação relacionada

- Índice geral dos capítulos: [README.md](README.md)
- Visão detalhada 29–36: [STEPS-29-36.md](STEPS-29-36.md)
- Encerramento do percurso: [MARCO-VI.md](MARCO-VI.md)

## Requisitos

Dart **3.11+** (null safety) para estes `pubspec.yaml`. Para `masmorra_ascii`, ver [../masmorra_ascii/README.md](../masmorra_ascii/README.md) (SDK ^3.5).
