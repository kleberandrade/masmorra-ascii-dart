# Capítulo 32 - Organização de Projeto: lib/, test/, pubspec.yaml

> *Você abre a gaveta de ferramentas. Está tudo lá: martelos, pregos, parafusos, serras. Mas está misturado. Gasta 10 minutos procurando a chave inglesa. Um carpinteiro experiente tem tudo organizado. Encontra em 2 segundos. Um projeto Dart bem organizado é assim.*

Um aventureiro não guardaria todas as suas armas, poções, mapas e tesouro no mesmo bolso. Mistura tudo, tudo se quebra, nada se encontra. Um aventureiro profissional tem mochilas temáticas: armas em um compartimento; poções em outro; ouro guardado com cuidado; mapas enrolados separados.

Um projeto Dart precisa da mesma organização profissional. Código de modelo em `lib/modelos/`, código de interface em `lib/ui/`, o ponto de entrada em `lib/main.dart`, testes em `test/`, configuração em `pubspec.yaml`. Você não coloca tudo em um único arquivo na raiz do projeto. Use **dart test** para rodar testes e **dart create** para gerar novos projetos. A **analysis_options.yaml** define regras de linting. Estrutura profissional torna fácil encontrar código, adicionar funcionalidades novas, reutilizar código em outros projetos, trabalhar em equipe.

## Estrutura de Projeto Dart

A estrutura de pastas de um projeto Dart profissional segue convenções que facilitam manutenção e escalabilidade. Você organiza código por domínio de responsabilidade: `model/` concentra dados e lógica de negócio, `ui/` tudo que renderiza ou interage com o usuário, `jogo/` a orquestração central, e assim por diante. Testes espelham essa mesma organização em `test/`. Isso não é aleatório; é uma convenção adotada pela comunidade Dart que torna projetos previsíveis e fáceis de navegar para qualquer desenvolvedor.

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

`lib/` é o coração do seu projeto—contém todo código que pode ser importado por outros projetos Dart. A razão para isso é simples: você quer que sua lógica de jogo seja independente da interface. Um dia você pode querer usar a mesma lógica em Flutter, em um servidor backend, ou compartilhada como um *package*. Ao isolar código reutilizável em `lib/`, você constrói para o futuro.

```dart
import 'package:masmorra_ascii/modelos/jogador.dart';
```

Organize por responsabilidade: `model/` para estruturas de dados e lógica de negócio, `ui/` para renderização, `jogo/` para o *loop* principal e orquestração, `combate/` para batalhas, `mundo/` para geração e manutenção do mapa. O ponto de entrada executável fica em `lib/main.dart`.

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

O arquivo `main.dart` é a porta de entrada do programa executável. Sua responsabilidade é única: orquestração de alto nível. Ele inicializa sistemas, mostra menu, delega trabalho para classes de domínio. Nunca contém lógica complexa de jogo; apenas coordena. Isso torna fácil testar lógica de jogo isoladamente (sem passar por `main.dart`) e mantém o programa limpo e compreensível.

```dart
// lib/main.dart
import 'jogo/dungeonCrawl.dart';
import 'persistencia/gerenciadorSalve.dart';
import 'dart:io';

void main() async {
  // ← inicializa persistência antes de qualquer lógica
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

  // ← switch despacha para funções especializadas
  switch (opcao) {
    case '1':
      await _novoJogo();
    case '2':
      await _carregarJogo();
    default:
      return;
  }
}

// ← função privada: novo jogo desde zero
Future<void> _novoJogo() async {
  stdout.write('Seu nome: > ');
  final nome = stdin.readLineSync() ?? 'Herói';

  final game = DungeonCrawl();
  game.iniciar(nome);
  game.executar();
}

// ← função privada: carregar jogo salvo
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

**Saída esperada:**

```text
MASMORRA ASCII: INÍCIO
──────────────────────────────────

1. Novo jogo
2. Carregar salve
3. Sair

Escolha: > 1
Seu nome: > Aventureiro
```

## Imports: Relativos em lib/, package: em test/

Quando você espalha código em múltiplos arquivos, precisa importar de um para o outro. Dentro de `lib/`, use *imports* relativos—são simples, diretos e tornam refatoração de pastas mais fácil. Em `test/`, use `package:` *imports* (convenção Dart para acessar código de `lib/` a partir de `test/`). A razão para isso é clara: `lib/` é seu código reutilizável; `test/` é código que testa o pacote *como se fosse um consumidor externo*. Assim você garante que seu pacote pode de fato ser importado por outros projetos sem problemas.

```dart
// Em lib/ — imports relativos ✓
import 'model/jogador.dart';
import 'combate/combate.dart';

// Em test/ — package: imports ✓
import 'package:masmorra_ascii/model/jogador.dart';
```

Imports relativos em `lib/` são claros: você sabe exatamente onde está o arquivo em relação ao arquivo atual. Imports `package:` em `test/` espelham como um usuário externo importaria seu código.

## pubspec.yaml: Dependências

O arquivo `pubspec.yaml` (abreviação de "pub spec") é o coração de metadados do seu projeto. Ele declara o nome, versão, dependências de produção, e dependências de desenvolvimento (dev_dependencies). Dependências de desenvolvimento como `test` e `lints` são usadas apenas durante desenvolvimento e testes; não são incluídas quando alguém usa seu código como *package*. Isso mantém seu *package* leve e sem poluição.

```yaml
name: masmorra_ascii
description: Roguelike ASCII em Dart puro
version: 1.0.0
publish_to: none  # ← impede publicação acidental em pub.dev

environment:
  sdk: '>=3.11.0 <4.0.0'  # ← requer Dart 3.11 ou superior

dependencies:
  # Puro Dart (nenhuma por enquanto)

dev_dependencies:
  test: ^1.25.0  # ← para escrever e rodar testes
  lints: ^3.0.0  # ← para análise estática de código
```

Executar o jogo:

```bash
$ dart lib/main.dart
```

Adicionar dependência de produção:

```bash
$ dart pub add http
```

Adicionar dependência de desenvolvimento (apenas para testes e análise):

```bash
$ dart pub add --dev coverage
```

**Saída esperada:**

```text
Added dependency 'http' to pubspec.yaml
Downloading http 1.1.0...
```

## analysis_options.yaml: Qualidade

Análise estática é um aliado silencioso. Enquanto você programa, `dart analyze` verifica padrões que levam a bugs: variáveis não usadas, falta de null checks, nomes inconsistentes, código morto. O arquivo `analysis_options.yaml` define regras que seu projeto deve seguir. Você começa com `package:lints/recommended.yaml` (recomendações oficiais Dart) e adiciona regras extras conforme necessário. Isso não é burocracia; é guardrails que evitam centenas de horas debugando depois.

```yaml
include: package:lints/recommended.yaml  # ← regras oficiais

linter:
  rules:
    - camel_case_types  # ← nomes de classes em PascalCase
    - constant_identifier_names  # ← constantes em UPPER_CASE
    - empty_constructor_bodies  # ← construtores vazios devem ser ;
    - prefer_const_constructors  # ← use const quando possível
    - prefer_const_declarations  # ← use const para constantes
    - prefer_final_fields  # ← campos não reatribuídos devem ser final
    - prefer_null_aware_operators  # ← use ?? em vez de if null
    - use_key_in_widget_constructors  # ← (para Flutter futuramente)
    - use_late_for_private_fields_and_variables  # ← lazy init
    - use_string_buffers  # ← concatenação em loop usa StringBuffer
    - use_to_close_over_close  # ← feche recursos que abrir
```

Execute análise:

```bash
$ dart analyze
```

**Saída esperada (zero problemas):**

```text
Analyzing masmorra_ascii...
No issues found!
```

Se houver problemas, o analyze lista cada um com localização exata para corrigir.

## Desafios da Masmorra

**Desafio 32.1. Arquitetura Profissional.** Todo projeto grande precisa de estrutura. Crie: `lib/model/` (dados), `lib/ui/` (renderização), `lib/jogo/` (loop principal), `lib/combate/` (batalha), `lib/mundo/` (mapa/geração), `lib/config/` (constantes), `lib/persistencia/` (save/load), `test/` (testes). Use `mkdir -p lib/model lib/ui lib/jogo lib/combate lib/mundo lib/config lib/persistencia test`. O ponto de entrada fica em `lib/main.dart`. Estrutura é como anatomia de um ser vivo: cada órgão em seu lugar. Dica: organize por domínio de negócio, não por tipo de código.

**Desafio 32.2. Reorganizar com Cuidado.** Mova cada arquivo para sua pasta: `Jogador` → `lib/model/jogador.dart`, `TelaAscii` → `lib/ui/tela.dart`, `MapaMasmorra` → `lib/mundo/mapa.dart`. Depois, atualize importações de `'jogador.dart'` para `'model/jogador.dart'`. Teste: `dart analyze` deve passar com zero erros. Se errar um import, código quebraria. Execute `dart lib/main.dart` para confirmar—jogo funciona igual. Dica: refatore arquivo por arquivo, não tudo de uma vez.

**Desafio 32.3. Metadados do Projeto.** Crie `pubspec.yaml` (coração do projeto): nome, versão, ambiente Dart, dev_dependencies. YAML é sensível a espaços (2 espaços). Exemplo mínimo: nome `masmorra_ascii`, versão `0.1.0`, sdk `>=3.11.0`, dev_dependencies: `test` e `lints`. Execute `dart pub get`. Dica: pubspec.yaml é o contrato do projeto.

**Desafio 32.4. Ponto de Entrada Limpo.** Revise `lib/main.dart` (arquivo executável). Deve ser fino: imports relativos e orquestração. Exemplo: `import 'jogo/jogo_principal.dart'; void main() async { await rodaJogo(); }`. Execute `dart lib/main.dart`. Lógica complexa fica nas subpastas de lib, main.dart é só porta de entrada. Dica: main.dart orquestra, não implementa.

**Boss Final 32.5. Pronto para Produção.** Integre tudo: (1) Reorg arquivos em pastas, (2) Update imports, (3) Configure pubspec.yaml e analysis_options.yaml, (4) Execute `dart analyze` → zero avisos, (5) Execute `dart test` → todos verdes, (6) Execute `dart lib/main.dart` → jogo funciona. Projeto é agora profissional, pronto para crescer, documentado e mantido. Dica: cada passo é um commit git: "refactor: move Jogador para lib/model".

## Por Que Não...?

**Por que não colocar tudo em um arquivo?** Você *poderia* colocar todo código em `lib/main.dart`, e funcionaria. Mas seu projeto viraria impossível de navegar em poucas semanas. Refatorar qualquer coisa quebraria tudo. Integrar com alguém seria caos. Reutilizar código em outro projeto? Impossível. Organização não é luxo; é fundação.

**Por que não usar imports relativos em `test/`?** Se você usar `import 'model/jogador.dart'` em teste, assume uma posição relativa específica de `test/` para `model/`. Se depois você move `model/` para outra pasta, todos testes quebram. Imports `package:` não se importam com posição; sempre funcionam enquanto o pacote existe. É por isso que é convenção em `test/`.

**Por que não omitir `analysis_options.yaml`?** Porque sem regras explícitas, cada desenvolvedor segue seu próprio padrão. Um escreve `camelCase`, outro `snake_case`. Um usa `??`, outro `if null`. Código fica inconsistente e confuso. `analysis_options.yaml` é acordado silencioso que torna código legível para todos.

## Pergaminho do Capítulo

Estrutura profissional estabelece fundações:
- `lib/` para código reutilizável, independente de interface
- `test/` espelhando `lib/`, testando pacote como consumidor externo
- `pubspec.yaml` declarando dependências, versão e metadados
- `analysis_options.yaml` impondo qualidade e consistência
- *Imports* relativos em `lib/`, `package:` em `test/`
- `main.dart` como orquestrador fino, não implementador

Um projeto bem organizado é dez vezes mais fácil de manter, e cem vezes mais fácil de estender.

::: dica
**Dica do Mestre:** Use `.gitignore`:

```text
.dart_tool/
pubspec.lock
.DS_Store
*.swp
```

Crie `README.md`:

````markdown
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
````
:::

## Próximo Capítulo

No Capítulo 33, adicionaremos a última camada de qualidade: testes *golden* que validam a aparência visual da HUD e um renderizador ASCII polido com barras de progresso e painéis informativos. Você começará a integrar a estrutura que construiu aqui com renderização visual, garantindo que a interface nunca quebra acidentalmente.
