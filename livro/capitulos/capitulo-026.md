# Capítulo 26 - Múltiplos Andares e o Boss Final

> *Você desceu profundamente. Os andares anteriores foram testes. Agora, nas profundezas, sente o ar mais pesado. Os inimigos mudam de forma. E no fundo, aguardando, existe algo antigo e poderoso. Não é um goblin aleatório. É o Rei da Masmorra, o boss final. Este capítulo é onde o jogo se torna épico, como Sephiroth em Final Fantasy VII ou Ganondorf em Zelda: múltiplas fases, cada uma mais perigosa.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Criar uma arquitetura de múltiplos andares com progressão dinâmica
- Implementar transição de andares (você encontra escada → novo andar gerado)
- Criar distribuições de inimigos e itens específicos por andar
- Implementar a classe `Chefao` que estende `Inimigo` com fases de combate
- Programar um sistema de fase (HP alto = ataque normal; HP médio = *fúria*; HP baixo = *desesperado*)
- Criar interfaces especiais para o combate contra *boss*
- Implementar uma enum `EstadoJogo` para rastrear estado global
- Criar telas de vitória e derrota com estatísticas épicas

Ao final, você terá um *roguelike* com campanha completa: exploração → *boss* → vitória/derrota.

## Arquitetura de Múltiplos Andares

Um *roguelike* não é um único andar plano. É uma progressão escalonada: cada andar é mais difícil que o anterior. Inimigos mais fortes, mais HP, itens raros aparecem. Isto mantém o jogo fresco: sempre há novo desafio, nunca fica trivial.

A estrutura de dificuldade por andar é clara e previsível:

```text
Andar 0: Iniciação
  ├─ Inimigos: Zumbis apenas (fracos)
  ├─ HP inimigo base: 10
  ├─ Ataque inimigo: 2
  ├─ Itens: Poções de vida
  └─ Objetivo: Aprender mecânicas (tutorial)

Andar 1: Desafio
  ├─ Inimigos: Zumbis + Lobos (mais variedade)
  ├─ HP inimigo base: 15 (+5 bônus)
  ├─ Ataque inimigo: 3 (+1 bônus)

Andar 2: Progressão
  ├─ Inimigos: Lobos + Esqueletos (mais fortes)
  ├─ HP inimigo base: 20 (+10 bônus)
  ├─ Ataque inimigo: 4 (+2 bônus)

Andar 3: Profundidade
  ├─ Inimigos: Esqueletos + Orcs (muito fortes)
  ├─ HP inimigo base: 30 (+20 bônus)
  ├─ Ataque inimigo: 6 (+4 bônus)

Andar 4: Trono do Rei
  ├─ Uma única sala grande (arena épica)
  ├─ Inimigo: *Boss* (Rei da Masmorra)
  ├─ HP: 150-200 (dinâmico conforme seu nível)
  ├─ Fases: Normal → *Fúria* → *Desesperado*
  └─ Vitória = fim do jogo (clímax)
```

**Nota de design:** Os bônus aumentam linearmente no início (0→5→10→20), depois há um salto grande para o *boss* (20→150). Isto é proposital: recompensa jogadores que chegam ao final, mas não torna impossível. Um jogador nível 5 enfrenta *boss* com ~150 HP (desafio extremo, possível com habilidades).

## Classe Chefao: Adversário Épico

O *boss* não é um inimigo normal. É inteligente e adapta-se conforme você o danifica. Tem fases claras: quando tem muita vida, ataca rotineiro. Quando perde 1/3 da vida, entra em *fúria* e ataca 50% mais forte (comportamento agressivo). Quando resta pouco, invoca poder ancestral e tenta *ataque crítico* (comportamento desesperado).

Cada fase muda tática e dano. Isto é psicologicamente importante: o *boss* não é uma bolsa de pancadas estática. Ele reage, adapta, fica perigoso conforme morre. Isto é exatamente como funcionam chefes em *Dark Souls*, *Zelda*, etc. Comportamento emergente mantém o combate tenso e emocionante até o final.

```dart
// lib/chefao.dart
import 'dart:math';

enum FaseChefao {
  normal,        // HP > 66%: comportamento controlado
  furia,         // 33% < HP <= 66%: agressivo
  desesperado,   // HP <= 33%: caótico e perigoso
}

class Chefao extends Inimigo {
  final Random _rng = Random();
  late int hpMaxOriginal;
  FaseChefao faseAtual = FaseChefao.normal;
  int ataqueBaseOriginal = 0;
  int modificadorDanoFase = 0;
  int turnosNaFase = 0;
  bool usouAtaqueEspecial = false;

  Chefao({
    String nome = 'Rei da Masmorra',
    int hpMax = 150,  // ← *Boss* tem muito HP (desafio real)
    int danoBase = 12,
  }) : super(
    nome: nome,
    hpMax: hpMax,
    ataque: danoBase,
    descricao: 'O ancião da masmorra. Olhos brilham com malícia.',
  ) {
    hpMaxOriginal = hpMax;
    ataqueBaseOriginal = danoBase;
  }

  /// Atualiza fase do boss baseado em % de HP
  /// ← padrão State implícito: cada fase tem comportamento diferente
  void atualizarFase() {
    final percentualHp = (hp / hpMax) * 100;

    if (percentualHp > 66) {
      // ← Fase 1: Normal (controladoe estável)
      if (faseAtual != FaseChefao.normal) {
        print('├─ O Rei permanece em controle...');
      }
      faseAtual = FaseChefao.normal;
      modificadorDanoFase = 0;
    } else if (percentualHp > 33) {
      // ← Fase 2: Fúria (agressividade aumenta)
      if (faseAtual != FaseChefao.furia) {
        print('\n[FÚRIA] O Rei entra em FÚRIA! Ataques devastadores!');
        print('   Dano aumentado em 50%!\n');
      }
      faseAtual = FaseChefao.furia;
      // ← +50% dano
      modificadorDanoFase = (ataqueBaseOriginal * 0.5).toInt();
    } else {
      // ← Fase 3: Desesperado (poder final, último recurso)
      if (faseAtual != FaseChefao.desesperado) {
        print('\n[DESESPERADO] O Rei tenta um golpe final!');
        print('   Chance de ataque crítico aumenta!\n');
      }
      faseAtual = FaseChefao.desesperado;
      // ← +75% dano
      modificadorDanoFase = (ataqueBaseOriginal * 0.75).toInt();
    }

    turnosNaFase++;  // ← rastreia duração em cada fase
  }

  @override
  void executarTurno(Jogador jogador) {
    atualizarFase();  // ← transição automática de fases

    print('\n--- Turno do $nome ---');

    // ← Fase 3 tem ataque especial (40% chance)
    if (faseAtual == FaseChefao.desesperado &&
        !usouAtaqueEspecial &&
        _rng.nextDouble() < 0.4) {
      _ataqueEspecial(jogador);
      usouAtaqueEspecial = true;  // ← usa apenas uma vez
    } else {
      // ← Ataque normal com variação (±15%)
      final dano = ataqueBaseOriginal + modificadorDanoFase;
      final variacao = (dano * 0.15).toInt();
      final danoFinal =
          dano - variacao + _rng.nextInt(variacao * 2 + 1);

      print('> $nome ataca com fúria!');

      if (faseAtual == FaseChefao.normal) {
        print('   (Ataque normal: $danoFinal dano)');
      } else if (faseAtual == FaseChefao.furia) {
        print('   (Ataque furioso: $danoFinal dano!)');
      } else {
        print('   (Ataque desesperado: $danoFinal dano!!!)');
      }

      jogador.sofrerDano(danoFinal);
    }
  }

  /// Ataque crítico quando em fase desesperada
  void _ataqueEspecial(Jogador jogador) {
    print('\n* O Rei invoca um poder ancestral!');
    print('   > RAIO ANCESTRAL atinge ${jogador.nome}!');

    // ← 2.5x dano crítico
    final danoCritico = (ataqueBaseOriginal * 2.5).toInt();
    jogador.sofrerDano(danoCritico);

    print('   Dano crítico: $danoCritico!');
  }

  String descreverStatus() {
    final percentualHp = (hp / hpMax) * 100;
    final faseTexto = switch (faseAtual) {
      FaseChefao.normal => '[OK] Normal',
      FaseChefao.furia => '[FÚRIA] Fúria (+50% dano)',
      FaseChefao.desesperado => '[CRÍTICO] Desesperado (+crítico)',
    };

    return '''
REI DA MASMORRA
────────────────────────────────────────
HP: $hp / $hpMax (${percentualHp.toStringAsFixed(0)}%)
Fase: $faseTexto
Descrição: $descricao
    ''';
  }

  @override
  String descreverAcao() {
    return switch (faseAtual) {
      FaseChefao.normal => '$nome respira profundamente.',
      FaseChefao.furia => '$nome RUGE e chamas envolvem a sala!',
      FaseChefao.desesperado =>
        '$nome invoca poder ancestral! O ar se torna tenso!',
    };
  }
}
```

**Saída esperada durante combate contra *boss*:**

```text
--- Turno do Rei da Masmorra ---
> Rei da Masmorra ataca com fúria!
   (Ataque normal: 11 dano)

[FÚRIA] O Rei entra em FÚRIA! Seus ataques se tornam devastadores!
   Dano aumentado em 50%!

--- Turno do Rei da Masmorra ---
> Rei da Masmorra ataca com fúria!
   (Ataque furioso: 17 dano!)

[DESESPERADO] Enfraquecido e DESESPERADO, o Rei tenta um ataque final!
   Chance de ataque crítico aumenta!

* O Rei invoca um poder ancestral!
   > RAIO ANCESTRAL atinge Guerreiro!
   Dano crítico: 30!
```

**Nota técnica:** O sistema de fases é um padrão State implícito. Cada fase é um estado (`FaseChefao` enum) que muda automaticamente conforme HP cai. No Capítulo 36 (referência), você aprenderá a implementar isso com classes State explícitas, mas aqui é simpler: um enum + `atualizarFase()` que transiciona automaticamente.

## Sistema de GameState

O jogo em qualquer momento está num estado bem-definido: explorando, combatendo, na loja, em pausa, morto, vencedor. Esta é a máquina de estados global do jogo. A classe `GerenciadorEstadoJogo` rastreia isto com um enum `EstadoJogo`, permitindo transições claras e até reverter ao estado anterior. Isto é arquiteturalmente importante: você sempre sabe em que "modo" o jogo está, facilita debugging e expansão futura (ex: "se em pausa, não processa movimento").

```dart
// lib/gerenciador_estado_jogo.dart

/// Estados globais do jogo
enum EstadoJogo {
  menuPrincipal,  // ← tela inicial
  explorando,     // ← dentro de um andar
  combatendo,     // ← em combate ativo
  naLoja,         // ← comprando itens
  subindoNivel,   // ← animação/apresentação de *level up*
  pausado,        // ← jogo congelado
  vitoria,        // ← derrotou o *boss*
  derrota,        // ← herói morreu
}

class GerenciadorEstadoJogo {
  EstadoJogo estadoAtual = EstadoJogo.menuPrincipal;
  EstadoJogo estadoAnterior = EstadoJogo.menuPrincipal;

  /// Transiciona para novo estado, rastreando o anterior
  void mudarPara(EstadoJogo novoEstado) {
    estadoAnterior = estadoAtual;
    estadoAtual = novoEstado;  // ← muda o estado
    print('\n→ Estado: ${estadoAtual.name}');  // ← feedback visual
  }

  /// Volta para estado anterior (ex: despausa)
  void voltarPara() {
    final temp = estadoAtual;
    estadoAtual = estadoAnterior;
    estadoAnterior = temp;  // ← permite ir e vir
  }

  /// Verifica se está em estado específico
  // ← query simples
  bool em(EstadoJogo estado) => estadoAtual == estado;
}
```

**Saída esperada ao gerenciar estados:**

```text
→ Estado: menuPrincipal
→ Estado: explorando
→ Estado: combatendo
→ Estado: subindoNivel
→ Estado: explorando
```

**Por que um gerenciador de estado global?** Porque sem isso, o código fica confuso: "Devo processar movimento se em combate?" "Posso pausar durante shop?" Com estados explícitos, tudo é claro. Cada sistema verifica `if (gerenciador.em(EstadoJogo.explorando))` e age apropriadamente.

## Progressão de Andares

A classe `GerenciadorAndares` encapsula toda a lógica de dificuldade por andar. Para cada andar (0-4), define: quanto HP extra os inimigos têm, quanto ataque extra ganham, quais tipos aparecem, que itens podem cair, descrição narrativa. Isto permite controle fino da curva de dificuldade.

**Design:** Centralizar configurações por andar em um único lugar é profissional. Se quiser tornar andar 2 mais fácil, muda um número. Tudo está junto, nada espalhado. Este é o padrão usado em qualquer jogo grande: database de níveis com multiplicadores por dificuldade.

```dart
// lib/gerenciador_andares.dart

/// Centraliza toda a configuração de dificuldade por andar
class GerenciadorAndares {
  int andarAtual = 0;
  final int andarFinal = 4;  // ← Andar 4 é o *boss*

  /// Retorna configuração do andar (bônus HP/ataque e inimigos)
  /// ← Design: tudo centralizado, fácil ajustar dificuldade
  (int hpBonus, int ataqueBonus, List<String> inimigos)
      configurarAndar(int numero) {
    return switch (numero) {
      // ← Tutorial
      0 => (hpBonus: 0, ataqueBonus: 0, inimigos: ['zumbi']),
      1 => (
        hpBonus: 10,
        ataqueBonus: 2,
        inimigos: ['zumbi', 'lobo'],  // ← Primeira variedade
      ),
      2 => (
        hpBonus: 20,
        ataqueBonus: 4,
        inimigos: ['lobo', 'esqueleto'],  // ← Aumenta dificuldade
      ),
      3 => (
        hpBonus: 35,
        ataqueBonus: 6,
        inimigos: ['esqueleto', 'orc'],  // ← Muito desafiador
      ),
      4 => (
        hpBonus: 60,
        ataqueBonus: 10,
        inimigos: ['chefao'],  // ← *Boss* final
      ),
      _ => (
        hpBonus: 100,
        ataqueBonus: 15,
        inimigos: ['chefao'],  // ← Fallback
      ),
    };
  }

  /// Itens que podem cair em cada andar
  /// ← Raros aumentam conforme desce (fácil vs veterano)
  List<String> itensPorAndar(int numero) {
    return switch (numero) {
      0 => ['pocaoVida', 'pocaoVida'],  // ← Muitas poções (treino)
      // ← Primeira arma rara
      1 => ['pocaoVida', 'pocaoVida', 'espadaFerro'],
      // ← Equipamento melhor
      2 => ['pocaoVida', 'espadaAco', 'escudoAco'],
      // ← Lendário
      3 => ['pocaoVida', 'espadaRunada', 'armaduraPesada'],
      4 => [],  // ← Boss não dropa itens (vitória = prêmio)
      _ => [],
    };
  }

  /// Narrativa de cada andar (texto descritivo)
  String descreverAndar(int numero) {
    return switch (numero) {
      0 => 'Você entra nas masmorras. Ar frio e úmido. Lodo no chão.',
      1 => 'O segundo andar é mais rochoso. Ecos de criaturas.',
      2 => 'Aqui, ossos cobrem o solo. A magia é palpável.',
      3 => 'Este é o andar da perdição. Auras malignas fluem.',
      4 =>
        // ← Épico
        'Câmara colossal. Trono antigo no centro. E nele, ELE.',
      _ => 'Um lugar estranho na masmorra.',
    };
  }

  bool ehAndarDoChefe() => andarAtual == andarFinal;  // ← Query útil
  bool ehUltimoAndar() => andarAtual >= andarFinal;   // ← Query útil
}
```

**Por que não usar herança para cada andar?** Você *poderia* criar classes `AndarZero extends Andar`, `AndarUm extends Andar`, etc. Mas seria overhead: cada classe teria 5 linhas. Um switch simples é mais leve e lógico aqui. Use herança quando há lógica compartilhada real, não só para dados.

## Telas de Vitória e Derrota

Quando o jogo termina, você não quer apenas "FIM". Quer celebração (vitória) ou epitáfio (derrota). A classe `TelaFimJogo` renderiza telas bonitas que mostram suas estatísticas: nível final, turnos vividos, inimigos derrotados, ouro coletado. Isto torna o fim memorável e satisfatório.

**Design psicológico:** A celebração visual é importante. Quando você derrota um *boss*, merece sentir glória. Um epitáfio é igualmente importante: morrer sem reconhecimento é frustrante. A tela transforma o fim de um jogo em um *momento* — algo que você conta depois.

```dart
// lib/tela_fim_jogo.dart

/// Renderiza tela final (vitória ou derrota) com estatísticas épicas
class TelaFimJogo {
  final Jogador jogador;
  final int andarAlcancado;
  final int totalTurnos;
  final int totalInimigosDefeitos;
  final int totalOuroColetado;
  final bool vitoria;  // ← determine qual tela mostrar

  TelaFimJogo({
    required this.jogador,
    required this.andarAlcancado,
    required this.totalTurnos,
    required this.totalInimigosDefeitos,
    required this.totalOuroColetado,
    required this.vitoria,
  });

  /// Exibe tela apropriada baseada em vitória/derrota
  void mostrar() {
    if (vitoria) {
      _mostrarVitoria();  // ← celebração
    } else {
      _mostrarDerrota();  // ← epitáfio
    }
  }

  /// Tela de vitória: celebração épica
  void _mostrarVitoria() {
    print('');
    print('VITÓRIA GLORIOSA!');
    print('');
    print('Você derrotou o Rei da Masmorra e libertou');
    print('o reino das sombras que o enfeitiçavam!');
    print('');
    print('ESTATÍSTICAS FINAIS');
    print('═' * 55);
    print('');
    // ← seu nome é memorizado
    print('Herói:          ${jogador.nome}');
    // ← quantos níveis alcançou?
    print('Nível Final:    ${jogador.nivel}');
    print('HP:             ${jogador.hp}/${jogador.hpMax}');
    print('Ataque:         ${jogador.ataque}');
    print('');
    print('CAMPANHA');  // ← estatísticas gerais
    print('─' * 55);
    print('Andares Explorados:   $andarAlcancado / 5');
    // ← quanto tempo demorou?
    print('Turnos Totais:        $totalTurnos');
    print('Inimigos Derrotados:  $totalInimigosDefeitos');
    print('Ouro Coletado:        $totalOuroColetado');
    print('');
    print('═' * 55);
    print('');
    print('Parabéns! Você completou Masmorra ASCII!');
    print('Sua lenda será contada nos séculos vindouros.');
    print('');
  }

  /// Tela de derrota: epitáfio respeitoso
  void _mostrarDerrota() {
    print('');
    print('DERROTA AMARGA');
    print('');
    print('Você caiu nas sombras da masmorra, derrotado');
    print('pelas forças que nela habitam.');
    print('');
    print('EPITÁFIO');  // ← homenagem ao herói caído
    print('═' * 55);
    print('');
    print('Aqui jaz ${jogador.nome}');  // ← seu nome é recordado
    print('Um herói de nível ${jogador.nivel}');
    print('');
    print('Caiu no andar $andarAlcancado');  // ← quão longe chegou?
    // ← quantas batalhas?
    print('Derrotou $totalInimigosDefeitos inimigos');
    print('Coletou $totalOuroColetado ouro');
    print('Viveu por $totalTurnos turnos');
    print('');
    print('═' * 55);
    print('');
    print('Nem toda jornada resulta em glória.');
    print('Mas sua tentativa é lembrada.');  // ← dignidade em derrota
    print('');
  }
}
```

**Saída esperada ao vencer:**

```text
VITÓRIA GLORIOSA!

Você derrotou o Rei da Masmorra e libertou
o reino das sombras que o enfeitiçavam!

ESTATÍSTICAS FINAIS
═══════════════════════════════════════════════════

Herói:          Guerreiro
Nível Final:    8
HP:             42/80
Ataque:         15

CAMPANHA
───────────────────────────────────────────────────
Andares Explorados:   5 / 5
Turnos Totais:        523
Inimigos Derrotados:  67
Ouro Coletado:        8500

═══════════════════════════════════════════════════

Parabéns! Você completou Masmorra ASCII!
Sua lenda será contada nos séculos vindouros.
```

**Nota psicológica:** A diferença entre "FIM" e uma tela de vitória é enorme. A primeira deixa o jogador vazio ("afinal, qual foi o ponto?"). A segunda deixa o jogador satisfeito ("completei, meus feitos foram reconhecidos"). Detalhes assim transformam um protótipo em um jogo verdadeiro.

## Desafios da Masmorra

**Desafio 26.1. Fúria do Chefão.** O Chefão Antigo entra em fúria quando ferido. Mude suas fases: de 66%/33% de HP para 75%/50% (fica furioso por mais tempo, mais ameaçador). Implemente em `atualizarFase()`. Teste: lute contra o boss, veja quando muda de fase. Sente-se mais desafiador? Dica: números importam na tensão.

**Desafio 26.2. Legiões da Sombra.** Ao entrar em fúria, o Chefão chama dois espectros: "Invocação de Sombras". Crie dois inimigos sombrios temporários (30% do HP do boss) que atacam ao seu lado. Implemente em `_ataqueEspecial()`. Teste: quando combater o boss na fase 2, dois aliados dele aparecem. Você precisa decidir: mata os espectros ou ataca o boss? Estratégia vital. Dica: use `List<Inimigo>` para gerenciar temporários.

**Desafio 26.3. A Arena Final.** O boss não aparece num andar procedural aleatório. Implemente `gerarSalaBoss()` que retorna uma única sala grande (80x20) limpa, só com chão. Boss no centro da sala, você spawna perto da entrada. Vasto, árido, épico. Implemente no gerador de andar final. Teste: descida ao boss deve se sentir diferente—solitário, vazio, apenas você vs ele. Dica: preencha com `Tile.chao`, coloque boss em coordenada específica.

**Desafio 26.4. O Prêmio da Vitória.** Ao derrotar o Chefão, você ganha a "Espada Ancestral Lendária" que aumenta Ataque em +10 permanentemente. Implemente na sequência de vitória: após mensagem de vitória, adicione item ao inventário. Teste: derrote o boss, veja o item aparecer. Você fica significativamente mais forte. Recompensa épica pelo sacrifício. Dica: `Jogador.adicionarItem()` com um objeto especial.

**Desafio 26.5. (Desafio): Jogo se Adapta a Você.** O jogo aprende de suas deficiências. Cada vitória aumenta dificuldade (+1, máx +5): inimigos 15% mais fortes. Cada derrota reduz (—1, mín —5): inimigos 15% mais fracos. Multiplicador final: `1.0 + (nível × 0.15)`. Isto cria curva de aprendizado: iniciante que morre muito fica em —5 (75% força), veterano vitorioso sobe em +5 (175% força). Teste 10 partidas com diferentes habilidades, veja dificuldade convergir. Dica: salve `nivelDificuldade` junto com stats.

**Boss Final 26.6. Troféu de Glória.** Na tela de vitória, mostre epopeia completa: (1) Tempo total (em minutos), (2) Ratio vitórias (inimigos derrotados / inimigos encontrados), (3) Andares conquistados, (4) Item mais valioso equipado. Crie uma bela tela ASCII que celebra a vitória com números. Teste: vitória deve ser momento satisfatório com reconhecimento dos seus feitos. Dica: rastreie `tempoInicio`, `inimigosDerrota`, `totalInimigos` durante o jogo.

## Comparação: Antes vs. Depois

### Antes (Sem Andares)

Tudo é um único andar infinito. Inimigos são sempre iguais. Sem progressão de dificuldade, sem clímax, sem fim definido. Jogar é chato.

```dart
// Inimigo nunca muda
final inimigo = Zumbi();
inimigo.hp = 10;  // Sempre 10
inimigo.ataque = 2;  // Sempre 2
```

### Depois (Com Andares e Boss)

Cada andar é progressivamente mais desafiador. Inimigos escalam. Há um clímax: o *boss*. Vitória é definida. Derrota é significativa. Jogar é emocionante.

```dart
final config = gerenciador.configurarAndar(3);
final inimigo = Esqueleto(
  hp: 20 + config.hpBonus,  // ← cresce por andar
  ataque: 4 + config.ataqueBonus,
);
```

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- `GerenciadorAndares` configura dificuldade, inimigos e itens por andar (dados centralizados)
- `Chefao` é um inimigo especial com fases (normal → *fúria* → *desesperado*, padrão State implícito)
- `EstadoJogo` enum rastreia o estado global do jogo (máquina de estados)
- Transição dinâmica: descida de andares com geração procedural
- Telas de *Game Over*: vitória e derrota com estatísticas completas (celebração vs. epitáfio)
- Integração: combate contra *boss* é o clímax de todo o sistema

Seu jogo agora é uma campanha completa: você começa fraco, progride através de 5 andares, enfrenta o chefe e vence ou perde. Isto é um verdadeiro *roguelike*.

**A estrutura de andares é o que transforma um protótipo em um produto: há começo, meio, fim, e clímax.**

## Dica Profissional

::: dica
**Dica do Mestre:** Curva de dificuldade é arte, não ciência. Teste com diferentes grupos de jogadores (reais, não só você): iniciantes devem passar no andar 1-2 no primeiro dia (sucesso imediato), intermediários devem chegar ao andar 3-4 em 2-3 dias, veteranos devem alcançar o *boss* em uma sessão. Reúna dados: em que andar a maioria morre? Quanto tempo leva cada andar? O *boss* é muito fácil ou quebra imersão? Cada feedback melhora a próxima iteração. Jogadores reais sempre revelam problemas que você (designer) nunca pensaria.
:::

## Próximo Capítulo

No Capítulo 27, vamos integrar tudo em uma versão completa e jogável do *roguelike*, com menu principal, seleção de dificuldade, e a jornada completa pronta para compartilhar.

***
