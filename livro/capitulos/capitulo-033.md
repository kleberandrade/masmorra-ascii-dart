# Capítulo 33 - Testes Golden e HUD ASCII Polido

> *Você testou comportamento—HP sobe, XP conta. Mas há uma dimensão que os testes nunca capturaram: o desenho na tela. Uma golden test captura a imagem de hoje e compara com amanhã. Se mudou sem permissão, o teste grita aviso.*

Você testou comportamento. HP sobe quando bebe poção, XP conta quando mata inimigo, combate funciona. Mas há uma dimensão que ninguém testava: o desenho. Como sabe se a HUD fica alinhada? Se as caixas estão desalinhadas? Se uma refatoração invisível quebrou a aparência?

Golden tests são screenshots testados. Você captura a saída ASCII exatamente como deveria parecer, salva esse "golden" (padrão de ouro), e depois, em cada mudança futura, compara. Se o desenho mudou, o teste falha. Você fica sabendo: foi intencional ou acidental?

Antes da batalha final, todo herói polida sua armadura. HUD polida e testes golden são esse polimento final. Não é apenas funcional; é profissional.

### Por que Testes Golden Importam?

Quando você está desenvolvendo um *roguelike*, a saída visual é tão importante quanto a lógica. Um herói com HP renderizado errado, estatísticas desalinhadas ou um mapa truncado pode parecer um bug crítico para o jogador. Golden tests são o seu escudo contra esses problemas invisíveis. Eles funcionam como patrulheiros noturnos da masmorra: capturam exatamente o que o jogador vê a cada frame, e se algo mudou (mesmo que acidentalmente), o alarme toca.

Imagine refatorar o sistema de renderização para otimizar performance. Você muda como barras de HP são desenhadas, reorganiza linhas da HUD, ajusta larguras. Sem Golden tests, você só descobre o problema quando começa a jogar e nota que tudo está estranho. Com Golden tests, o teste falha imediatamente, avisando que algo visual mudou—intencional ou não.

## Golden Tests: Snapshots de Saída

Um *golden test* (teste padrão de ouro) captura a saída visual exatamente como deveria ser e a valida em futuras execuções. O fluxo é simples:

1. **Executa código**, coleta a saída textual (neste caso, o ASCII renderizado da HUD)
2. **Primeira execução**: cria arquivo "golden" (baseline) com a saída esperada
3. **Próximas execuções**: compara saída atual com baseline; se mudou, o teste falha
4. **Mudança intencional**: você revisa a diferença, confirma que é desejada, e atualiza o golden

Por que isso importa? Refatorar código de renderização é perigoso. Você muda um detalhe—espaçamento, caractere de barra, alinhamento—e acidentalmente quebra a aparência para o jogador. Sem *golden tests*, você só descobre ao jogar. Com eles, o teste grita: "Ei, algo visual mudou!" Você revisa, confirma se foi intencional, e segue.

Esse padrão é padrão-ouro em teste visual. Engines gráficas (Unity, Godot) comparam pixels. Em um *roguelike* ASCII, comparamos strings. A ideia é idêntica: capturar e validar saída visual através de regressão.

O código abaixo implementa um *golden test* básico. Ele renderiza o status do jogador, e se o arquivo golden não existe, cria um. Se existe, valida que a saída atual bate com o padrão salvo:

```dart
// test/ui/hud_golden_test.dart
import 'package:test/test.dart';
import 'package:masmorra_ascii/ui/renderizador.dart';
import 'dart:io';

void main() {
  group('Golden Tests', () {
    test('renderizar status jogador', () {
      final render = Renderizador();
      final jogador = Jogador(
        nome: 'Herói',
        hpMax: 50,
        ataque: 10,
      );
      jogador.hpAtual = 35;  // ← 70% de HP
      jogador.xp = 120;
      jogador.nivel = 5;

      final output = render.renderizarStatus(jogador);

      final goldenFile = File('test/golden/status.txt');
      if (goldenFile.existsSync()) {
        // ← segunda e próximas execuções: compara com padrão
        final golden = goldenFile.readAsStringSync();
        expect(output, equals(golden),
          reason: 'HUD diferente do padrão. Verifique alinhamento.');
      } else {
        // ← primeira execução: cria o arquivo golden
        goldenFile.parent.createSync(recursive: true);
        goldenFile.writeAsStringSync(output);
        print('Golden criado em: ${goldenFile.path}');
      }
    });

    test('renderizar mapa inteiro', () {
      final render = Renderizador();
      final mapa = MapaMasmorra(largura: 20, altura: 10);
      final jogador = Jogador(nome: 'Herói')..pos = Offset(5, 5);
      final inimigos = [
        // ← E (inimigo)
        Inimigo(tipo: TipoInimigo.goblin)..pos = Offset(8, 7),
        // ← E (inimigo)
        Inimigo(tipo: TipoInimigo.orc)..pos = Offset(12, 3),
      ];

      final output = render.renderizarMapa(mapa, jogador, inimigos);
      final goldenFile = File('test/golden/mapa.txt');

      if (goldenFile.existsSync()) {
        // ← compara com padrão salvo
        expect(output, equals(goldenFile.readAsStringSync()));
      } else {
        // ← primeira execução: cria padrão
        goldenFile.parent.createSync(recursive: true);
        goldenFile.writeAsStringSync(output);
      }
    });
  });
}
```

**Quando usar Golden tests:**
- Quando a saída visual é crítica (HUD, mapa, log de combate)
- Quando você refatora código de renderização e quer garantir que nada mudou visualmente
- Quando colabora com outras pessoas e precisa rastrear mudanças de UI no git
- Quando você quer testar casos complexos (barra de HP com 7%, posição de inimigos específica, alinhamento com nomes longos)

## HUD Polida: Renderização Profissional

Uma HUD profissional não é apenas texto amontoado. Ela alinha itens visualmente, usa linhas simples para organizar informações, mostra barras visuais em vez de números crus (uma barra de HP preenchida é mais intuitiva que "45/50"). A qualidade da interface comunica ao jogador: "este jogo foi feito com esmero."

**Por que isso importa:** Em um *roguelike* ASCII, a interface é tudo que o jogador vê. Não há gráficos 3D para compensar um layout ruim. Informações bem alinhadas, barras bem preenchidas, números bem espaçados—tudo isso comunica profissionalismo e torna o jogo legível em combate intenso. Um mapa desalinhado causa confusão; uma barra truncada esconde informação crítica.

**Técnicas chave que vamos usar:**
- ***StringBuffer***: Construir strings linha por linha é eficiente. Em vez de concatenar com `+` a cada linha (O(n²) complexidade), você acumula tudo em um buffer e chama `toString()` ao final (O(n)). Para HUD com 20+ linhas, a diferença é significativa.
- **Métodos *helpers* privados**: `_centralizar()`, `_barra()`, etc. Reutilizáveis, testáveis isoladamente, e reduzem repetição.
- **Caracteres de desenho**: `─`, `═`, `█`, `░` criam separadores e barras visualmente claros sem ASCII elaborado.

Aqui está um `Renderizador` completo que encapsula essas técnicas:

```dart
// lib/ui/renderizador.dart
class Renderizador {
  // ← padrão em terminais (mantém compatibilidade)
  static const int largura = 80;

  /// Renderiza o painel de status do jogador com barras visuais.
  /// Mostra: nome, HP com barra, nível, ataque e XP acumulado.
  /// Usa StringBuffer para eficiência; não concatena com `+` em loop.
  String renderizarStatus(Jogador j) {
    final buffer = StringBuffer();

    // Nome centralizado para destaque visual
    buffer.writeln(_centralizar(j.nome, largura));

    // Separador de topo
    buffer.writeln('─' * largura);

    // HP: barra visual + percentual (mais intuitivo que números crus)
    final barraHp = _barra(j.hpAtual, j.hpMax, 20);
    final niv = j.nivel.toString().padRight(2);
    buffer.writeln('HP: [$barraHp] | Nível: $niv');

    // Ataque (modificador) e XP acumulado
    final atk = j.ataque.toString().padRight(2);
    final xp = j.xp.toString().padRight(5);
    buffer.writeln('Ataque: $atk | XP: $xp');

    // Separador final (delimita painel)
    buffer.writeln('─' * largura);

    return buffer.toString();
  }

  /// Centraliza texto. Se maior que `largura`, retorna intacto.
  /// Usado para nomes de personagens e títulos que devem destacar.
  String _centralizar(String texto, int largura) {
    if (texto.length >= largura) return texto;
    final padding = (largura - texto.length) ~/ 2;
    return texto.padRight(padding + texto.length).padLeft(largura);
  }

  /// Desenha barra visual (█ preenchido, ░ vazio) com percentual.
  /// Ex.: _barra(35, 50, 20) dá 14 blocos cheios, 6 vazios, "70%".
  /// Mais intuitivo que "35/50": você lê visual em combate rápido.
  String _barra(int atual, int maximo, int largura) {
    if (maximo == 0) maximo = 1; // ← evita divisão por zero (edge case)

    final preenchido = (atual / maximo * largura).toInt();
    final vazio = largura - preenchido;
    final pct = (atual / maximo * 100).toInt();

    final p = pct.toString().padLeft(3);
    return '█' * preenchido + '░' * vazio + ' $p%';
  }

  /// Renderiza o mapa da masmorra com posição do jogador e inimigos.
  /// @ = jogador, E = inimigo, . = vazio
  /// Permite jogador "ler" o mapa inteiro com visão tática.
  String renderizarMapa(
      MapaMasmorra m, Jogador j, List<Inimigo> inimigos) {
    final buffer = StringBuffer();
    buffer.writeln('─ Mapa ' + '─' * (largura - 7));

    for (int y = 0; y < m.altura; y++) {
      // ← indentação para não colar na borda esquerda
      buffer.write('  ');
      for (int x = 0; x < m.largura; x++) {
        final pos = Offset(x.toDouble(), y.toDouble());
        if (pos == j.pos) {
          buffer.write('@');  // ← Posição do jogador
        } else if (inimigos.any((e) => e.pos == pos)) {
          buffer.write('E');  // ← Inimigo
        } else {
          buffer.write('.');  // ← Vazio
        }
      }
      buffer.writeln();
    }

    buffer.writeln('─' * largura);
    return buffer.toString();
  }

/// Renderiza o log de combate (últimas ações: ataques, poções, danos).
 
  /// Mostra apenas os 5 últimos eventos para não poluir a tela.
  /// Útil para o jogador entender o que aconteceu na masmorra.
  String renderizarLog(List<String> eventos) {
    final buffer = StringBuffer();
    buffer.writeln('─ Log de Combate ' + '─' * (largura - 17));

    // Mostra apenas os 5 últimos eventos para não poluir tela
    final mostrados = eventos.length > 5
      ? eventos.sublist(eventos.length - 5)
      : eventos;

    for (final evento in mostrados) {
      // ← trunca eventos muito longos para caber na largura
      final truncado = evento.length > largura - 4
        ? evento.substring(0, largura - 7) + '...'
        : evento;
      buffer.writeln('  $truncado');
    }

    buffer.writeln('─' * largura);
    return buffer.toString();
  }
}
```

**Notas de design:**
- A constante `largura = 80` é padrão em terminais desde os anos 80 (terminais VT100). Respeitar isso torna o jogo compatível em qualquer terminal, em qualquer máquina. É escolha pragmática, não estética.
- *StringBuffer* é mais eficiente que concatenação com `+` em loops ou múltiplas strings. Concatenação cria cópia a cada `+`; *StringBuffer* acumula internamente. Para HUD com 20+ linhas, a diferença é tangível em performance.
- Métodos privados (`_barra`, `_centralizar`) agrupam lógica reutilizável e testável. Você pode testar `_barra()` isoladamente sem dependência de `Jogador` ou `MapaMasmorra`. Isso é composição em ação.

**Integração com Capítulo 32:** Você organizou código em `lib/ui/` no capítulo anterior; agora você implementa o conteúdo. A estrutura habilita a especialização. Renderizador vive isolado em `lib/ui/renderizador.dart`, testado com *golden tests*, e pode ser reutilizado em múltiplos contextos (terminal, Flutter, web, etc.).

### O Jogo Até Aqui

Ao final desta parte, seu jogo com HUD polido no terminal se parece com isto:

```text
MASMORRA - Andar 3 (Normal)     Turno: 87

  ################
  #..............#
  #..@...........#
  #.........G....#
  #..............#
  #######..#######
        #..#
  #######..#######
  #..............#
  #.....Z.....$..#
  #..............>
  ################

Herói (Nv.5)
  HP: [████████░░░░] 80/100
  XP: [██████░░░░░░] 620/1000
  Ouro: 850 | Ataque: +12 | Defesa: +8
  Inventário: Espada Aço, Armadura, Poção x2

[SALVO] >
```

Cada parte adiciona novas camadas ao jogo. Compare com o início e veja o quanto você evoluiu!

***


**Desafio 33.1. Padrão de Ouro.** Golden tests são screenshots de texto: você captura a HUD "perfeita", salva em arquivo, e valida que futuros testes batem. Crie um: Jogador "Aventureiro" com HP 30/40, nível 3, ataque 7. Chame `render.renderizarStatus(jogador)`. Primeira execução cria arquivo golden `test/golden/status.txt`. Execute novamente: deve passar (saída confere). É seu seguro contra regressões visuais. Dica: golden test é padrão em testes visuais.

**Desafio 33.2. Artesão de Barras.** Barra de progresso é arte. Implemente `_barra(atual, max, largura)` que retorna string com blocos: `█` cheio, `░` vazio. Teste 4 casos: (1) barra cheia (50/50), (2) metade (25/50), (3) quase vazia (5/50), (4) vazia (0/50). Valide percentuais: `50/50` → "100%", `25/50` → "50%". Trate `max == 0` sem dividir por zero. Barras visuais contam história do progresso. Dica: `(current * width) ~/ max` calcula quantos blocos.

**Desafio 33.3. HUD que Respira.** Renderizar HUD bonita é combinar múltiplas caixas alinhadas. Teste Golden que renderiza: (1) status do jogador (nome, HP com barra, nível, XP), (2) mapa 20x10 (@=jogador, E=inimigo, .=chão, #=parede), (3) lado a lado em layout profissional. Salve em `test/golden/hud_completo.txt`. Todas caixas mesma largura (80), alinhadas. Veja: HUD é janela para estado do jogo. Dica: construa com `StringBuffer`, linha por linha.

**Desafio 33.4. Galeria de Cenários.** Não existe um único estado "correto"—*roguelike* tem 100 situações. Crie 4 goldens para extremos: (1) `status_novo.txt` (nível 1, HP cheio, XP 0), (2) `status_critico.txt` (1 HP / 50, nível 9, XP máximo), (3) `mapa_vazio.txt` (você sozinho), (4) `mapa_cercado.txt` (você rodeado por 4 inimigos). Cada captura um estado. Execute testes: todos criam goldens. Agora refatore renderizador—testes vão falhar (desejado). Dica: cenários extremos expõem bugs que casos normais ocultam.

**Desafio 33.5. Refatoração Auditada.** Você quer melhorar renderizador. Implemente 4 testes golden acima, execute para criar goldens. Depois refatore: mude largura de 80 para 100, adicione timestamp, altere barra de `█` para `#`. Execute testes—falharão (golden velho vs novo). Revise os `.txt`, confirme mudanças são intencionais. Se sim: delete goldens antigos, execute testes, criem novos. Git mostra exatamente que mudou. Regressão visual é impossível agora. Dica: `git diff test/golden/` mostra antes/depois visualmente.

**Boss Final 33.6. Progressão Cinematográfica.** Golden tests + progressão. Setup: Jogador nível 1, 0 XP, HP cheio. (1) Teste Golden `prog_nivel1.txt`: renderize estado inicial. (2) `prog_nivel2.txt`: ganhe XP para 30%, nível ainda 1 mas barra mudou. (3) `prog_sobe.txt`: ganhe o XP faltante, nível sobe para 2, barra reseta, HP restaura, ataque aumenta—veja em tela. (4) Repita até nível 3. Crie 5+ arquivos golden que contam a jornada. Cada golden é um frame de filme. Seu teste de integração valida lógica + visual simultaneamente. Dica: isso é teste de integração real—lógica (XP) + renderização juntas.

## Por Que Não...?

**Por que não usar *mocks* ou snapshots fotográficos?** *Mocks* testam comportamento, não aparência. Snapshots fotográficos são específicos de plataforma (PNG em Windows ≠ PNG em Mac por diferenças de rendering). Strings de saída são portáveis e legíveis em diff. *Golden tests* com strings ganham.

**Por que não concatenar strings com `+`?** Você *poderia*, e em pequenas escalas funciona. Mas concatenação com `+` é O(n²) porque cada `+` cria cópia. Para 20 linhas de HUD, são 20 cópias. Para 100 linhas, são 10.000 operações. *StringBuffer* é O(n) e invisívelmente mais rápido.

**Por que não usar uma biblioteca de renderização como ncurses?** ncurses adiciona dependência pesada para um jogo ASCII. Seu *Renderizador* simples é 100 linhas de Dart puro que você controla completamente. Adicionar ncurses seria sobre-engenharia. YAGNI: "You Aren't Gonna Need It."

## Pergaminho do Capítulo

**Golden tests** (*snapshots* de saída textual) capturam HUD exatamente como deveria parecer e a validam em testes futuros. Se algo visual muda, o teste falha, avisando se foi acidental ou intencional. Esse padrão é padrão-ouro em teste visual.

**HUD polida** usa *StringBuffer* para construir strings eficientemente (O(n) em vez de O(n²)), métodos *helpers* privados para evitar repetição, e caracteres de desenho (`─`, `█`, `░`) para parecer profissional. Tudo alinhado e testável.

**Quando usar *golden tests*:**
- Refatorar código de renderização → testes garantem que nada quebrou visualmente
- Colaborar em time → rastreie mudanças de *UI* no git (diffs são claros)
- Testar casos complexos → barras em 7%, inimigos em posições específicas, nomes longos

**Workflow típico:**
1. Primeira execução: teste cria arquivo *golden* (baseline)
2. Próximas execuções: teste valida que saída atual confere
3. Se refatorou propositalmente: revisa diferença e atualiza *golden* após confirmar intenção

Golden tests são seu seguro contra regressão visual. Em um *roguelike* ASCII, a interface é tudo que o jogador vê.

::: dica
**Dica do Mestre:** Commit goldens com código:

```bash
git add test/golden/
git add lib/ui/
```

Rastreie mudanças de UI no histórico. Assim, quando você volta no git log, vê exatamente como a HUD era em cada versão. É como um screenshotting automático.

**Bonus:** Use `git diff test/golden/status.txt` para ver antes/depois visualmente quando você refatora. Muito útil para validar mudanças.
:::

**Saída esperada (primeira execução de golden test):**

```text
Golden criado em: test/golden/status.txt
```

Depois, o arquivo `test/golden/status.txt` contém:

```text
                          Aventureiro
──────────────────────────────────────────────────────────────────────
HP: [█████████████░░░░░░░░░░░░░░░░░░░░░░░░ 70%] | Nível:  5
Ataque: 12 | XP: 450
──────────────────────────────────────────────────────────────────────
```

Próximas execuções: teste passa silenciosamente (saída atual = golden salvo). Se refatorar renderização e mudar a saída, o teste falha com diferença clara.

## Próximo Capítulo

No Capítulo 34, entramos no território dos padrões de projeto. *Strategy* e *Command* darão inteligência aos inimigos — cada um com comportamento próprio que pode ser trocado em tempo de execução. A interface polida que construiu aqui vai exibir uma IA sofisticada funcionando por trás.
