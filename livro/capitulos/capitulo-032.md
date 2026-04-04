# Capítulo 32 - Organização de Projeto: lib/, test/, pubspec.yaml

> *Você abre a gaveta de ferramentas. Está tudo lá: martelos, pregos, parafusos, serras. Mas está misturado. Gasta 10 minutos procurando a chave inglesa. Um carpinteiro experiente tem tudo organizado. Encontra em 2 segundos. Um projeto Dart bem organizado é assim.*

Um aventureiro não guardaria todas as suas armas, poções, mapas e tesouro no mesmo bolso. Mistura tudo, tudo se quebra, nada se encontra. Um aventureiro profissional tem mochilas temáticas: armas em um compartimento; poções em outro; ouro guardado com cuidado; mapas enrolados separados.

Um projeto Dart precisa da mesma organização profissional. Código de modelo em `lib/modelos/`, código de interface em `lib/ui/`, o ponto de entrada em `lib/main.dart`, testes em `test/`, configuração em `pubspec.yaml`. Você não coloca tudo em um único arquivo na raiz do projeto. Use **dart test** para rodar testes e **dart create** para gerar novos projetos. A **analysis_options.yaml** define regras de linting. Estrutura profissional torna fácil encontrar código, adicionar funcionalidades novas, reutilizar código em outros projetos, trabalhar em equipe.

## Estrutura de Projeto Dart

```text
masmorra_ascii/
  lib/
    main.dart
    model/
      jogador.dart
      inimigo.dart
      item.dart
    ui/
      telaascii.dart
      renderizador.dart
    jogo/
      dungeonCrawl.dart
      estadoJogo.dart
      parseador.dart
    combate/
      combate.dart
    mundo/
      mapaMasmorra.dart
    config/
      constantes.dart
    persistencia/
      gerenciadorSalve.dart
  test/
    model/
    jogo/
    combate/
  pubspec.yaml
  analysis_options.yaml
  README.md
```

### lib/: Código Reutilizável

`lib/` contém código importável por outros projetos:

```dart
import 'package:masmorra_ascii/modelos/jogador.dart';
```

Organize por responsabilidade: `model/`, `ui/`, `jogo/`, `combate/`, `mundo/`. O ponto de entrada fica em `lib/main.dart`.

### test/: Testes

Espelha `lib/`:

```text
test/
  model/
    jogador_test.dart
  jogo/
    parseador_test.dart
```

### pubspec.yaml: Configuração

```yaml
name: masmorra_ascii
description: Roguelike ASCII em Dart
version: 1.0.0

environment:
  sdk: '>=3.11.0 <4.0.0'

dependencies:

dev_dependencies:
  test: ^1.25.0
  lints: ^3.0.0
```

## lib/main.dart: Ponto de Entrada

```dart
// lib/main.dart

import 'jogo/dungeonCrawl.dart';
import 'persistencia/gerenciadorSalve.dart';
import 'dart:io';

void main() async {
  await GerenciadorSalve.inicializar();

  print('');
  print('MASMORRA ASCII: INÍCIO');
  print('─' * 30);
  print('');

  print('1. Novo jogo');
  print('2. Carregar salve');
  print('3. Sair');
  print('');

  stdout.write('Escolha: > ');
  final opcao = stdin.readLineSync() ?? '3';

  switch (opcao) {
    case '1':
      await _novoJogo();
    case '2':
      await _carregarJogo();
    default:
      return;
  }
}

Future<void> _novoJogo() async {
  stdout.write('Seu nome: > ');
  final nome = stdin.readLineSync() ?? 'Herói';

  final game = DungeonCrawl();
  game.iniciar(nome);
  game.executar();
}

Future<void> _carregarJogo() async {
  final salves = await GerenciadorSalve.listarSalves();

  for (int i = 0; i < salves.length; i++) {
    if (salves[i] != null) {
      print('  $i. ${salves[i]}');
    } else {
      print('  $i. [Vazio]');
    }
  }

  stdout.write('Slot: > ');
  final slot = int.parse(stdin.readLineSync() ?? '0');

  final estado = await GerenciadorSalve.carregar(slot);
  if (estado == null) {
    print('Erro ao carregar');
    return;
  }

  final game = DungeonCrawl()..estado = estado;
  game.executar();
}
```

## Imports: Relativos em lib/, package: em test/

Quando você espalha código em múltiplos arquivos, precisa importar de um para o outro. Dentro de `lib/`, use imports relativos—são simples e diretos. Em `test/`, use `package:` imports (convenção Dart para acessar código de `lib/` a partir de `test/`).

```dart
// Em lib/ — imports relativos ✓
import 'model/jogador.dart';
import 'combate/combate.dart';

// Em test/ — package: imports ✓
import 'package:masmorra_ascii/model/jogador.dart';
```

Imports relativos em `lib/` são claros: você sabe exatamente onde está o arquivo em relação ao arquivo atual.

## pubspec.yaml: Dependências

```yaml
name: masmorra_ascii
description: Roguelike ASCII em Dart puro
version: 1.0.0
publish_to: none

environment:
  sdk: '>=3.11.0 <4.0.0'

dependencies:
  # Puro Dart (nenhuma por enquanto)

dev_dependencies:
  test: ^1.25.0
  lints: ^3.0.0
```

Executar o jogo:

```bash
$ dart lib/main.dart
```

Adicionar dependência:

```bash
$ dart pub add http
$ dart pub add --dev coverage
```

## analysis_options.yaml: Qualidade

```yaml
include: package:lints/recommended.yaml

linter:
  rules:
    - camel_case_types
    - constant_identifier_names
    - empty_constructor_bodies
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_null_aware_operators
    - use_key_in_widget_constructors
    - use_late_for_private_fields_and_variables
    - use_string_buffers
    - use_to_close_over_close
```

Execute:

```bash
$ dart analyze
```

Esperado: zero avisos.

## Desafios da Masmorra

**Desafio 32.1. Arquitetura Profissional.** Todo projeto grande precisa de estrutura. Crie: `lib/model/` (dados), `lib/ui/` (renderização), `lib/jogo/` (loop principal), `lib/combate/` (batalha), `lib/mundo/` (mapa/geração), `lib/config/` (constantes), `lib/persistencia/` (save/load), `test/` (testes). Use `mkdir -p lib/model lib/ui lib/jogo lib/combate lib/mundo lib/config lib/persistencia test`. O ponto de entrada fica em `lib/main.dart`. Estrutura é como anatomia de um ser vivo: cada órgão em seu lugar. Dica: organize por domínio de negócio, não por tipo de código.

**Desafio 32.2. Reorganizar com Cuidado.** Mova cada arquivo para sua pasta: `Jogador` → `lib/model/jogador.dart`, `TelaAscii` → `lib/ui/tela.dart`, `MapaMasmorra` → `lib/mundo/mapa.dart`. Depois, atualize importações de `'jogador.dart'` para `'model/jogador.dart'`. Teste: `dart analyze` deve passar com zero erros. Se errar um import, código quebraria. Execute `dart lib/main.dart` para confirmar—jogo funciona igual. Dica: refatore arquivo por arquivo, não tudo de uma vez.

**Desafio 32.3. Metadados do Projeto.** Crie `pubspec.yaml` (coração do projeto): nome, versão, ambiente Dart, dev_dependencies. YAML é sensível a espaços (2 espaços). Exemplo mínimo: nome `masmorra_ascii`, versão `0.1.0`, sdk `>=3.11.0`, dev_dependencies: `test` e `lints`. Execute `dart pub get`. Dica: pubspec.yaml é o contrato do projeto.

**Desafio 32.4. Ponto de Entrada Limpo.** Revise `lib/main.dart` (arquivo executável). Deve ser fino: imports relativos e orquestração. Exemplo: `import 'jogo/jogo_principal.dart'; void main() async { await rodaJogo(); }`. Execute `dart lib/main.dart`. Lógica complexa fica nas subpastas de lib, main.dart é só porta de entrada. Dica: main.dart orquestra, não implementa.

**Boss Final 32.5. Pronto para Produção.** Integre tudo: (1) Reorg arquivos em pastas, (2) Update imports, (3) Configure pubspec.yaml e analysis_options.yaml, (4) Execute `dart analyze` → zero avisos, (5) Execute `dart test` → todos verdes, (6) Execute `dart lib/main.dart` → jogo funciona. Projeto é agora profissional, pronto para crescer, documentado e mantido. Dica: cada passo é um commit git: "refactor: move Jogador para lib/model".

## Pergaminho do Capítulo

Estrutura profissional:
- `lib/` para código reutilizável e ponto de entrada (`main.dart`)
- `test/` espelhando `lib/`
- `pubspec.yaml` controlando dependências
- `analysis_options.yaml` impondo qualidade
- Imports relativos em `lib/`, `package:` em `test/`

Um projeto bem organizado é dez vezes mais fácil de manter.

::: dica
**Dica do Mestre:** Use `.gitignore`:

```text
.dart_tool/
pubspec.lock
.DS_Store
*.swp
```

Crie `README.md`:

```markdown
# Masmorra ASCII

Roguelike ASCII em Dart puro.

## Como Jogar

```bash
dart lib/main.dart
```

## Testes

```bash
dart test
```
:::

No próximo capítulo você vai implementar testes Golden: screenshots ASCII verificados uma vez, depois comparados com mudanças futuras.
