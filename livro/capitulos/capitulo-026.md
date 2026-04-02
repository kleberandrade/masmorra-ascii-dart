# Capítulo 26 - Múltiplos Andares e o Boss Final

> *Você desceu profundamente. Os andares anteriores foram teste. Agora, nas profundezas, sente o ar mais pesado. Os inimigos mudam de forma. E no fundo, aguardando, existe algo antigo e poderoso. Não é um goblin aleatório. É o Rei da Masmorra, o boss final. Este capítulo é onde o jogo se torna épico, como Sephiroth em Final Fantasy VII ou Ganondorf em Zelda: múltiplas fases, cada uma mais perigosa.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Criar uma arquitetura de múltiplos andares com progressão dinâmica
- Implementar transição de andares (você encontra escada → novo andar gerado)
- Criar distribuições de inimigos e itens específicos por andar
- Implementar a classe `Chefao` que estende `Inimigo` com fases de combate
- Programar um sistema de fase (HP alto = ataque normal; HP médio = fúria; HP baixo = desesperado)
- Criar interfaces especiais para o combate contra boss
- Implementar uma enum `EstadoJogo` para rastrear estado global
- Criar telas de vitória e derrota com estatísticas épicas

Ao final, você terá um roguelike com campanha completa: exploração → boss → vitória/derrota.

## Arquitetura de Múltiplos Andares

Estrutura de dificuldade por andar:

```text
Andar 0: Iniciação
  ├─ Inimigos: Zumbis apenas
  ├─ HP inimigo base: 10
  ├─ Ataque inimigo: 2
  ├─ Itens: Poções de vida
  └─ Objetivo: Aprender mecânicas

Andar 1: Desafio
  ├─ Inimigos: Zumbis + Lobos
  ├─ HP inimigo base: 15
  ├─ Ataque inimigo: 3

Andar 2: Progressão
  ├─ Inimigos: Lobos + Esqueletos
  ├─ HP inimigo base: 20
  ├─ Ataque inimigo: 4

Andar 3: Profundidade
  ├─ Inimigos: Esqueletos + Orcs
  ├─ HP inimigo base: 30
  ├─ Ataque inimigo: 6

Andar 4: Trono do Rei
  ├─ Uma única sala grande
  ├─ Inimigo: Boss (Rei da Masmorra)
  ├─ HP: 150-200 (dinâmico conforme seu nível)
  ├─ Fases: Normal → Fúria → Desesperado
  └─ Vitória = fim do jogo
```

## Classe Chefao: Adversário Épico

O chefe não é um inimigo normal. Tem fases: quando tem muita vida, ataca normal. Quando perde 1/3 da vida, entra em fúria e ataca 50% mais forte. Quando resta pouco, invoca poder ancestral e tenta ataque crítico. Cada fase muda o comportamento, mantendo o combate emocionante e dinâmico.

```dart
// lib/chefao.dart

import 'dart:math';

enum FaseChefao {
  normal,        // HP > 66%
  furia,         // 33% < HP <= 66%
  desesperado,   // HP <= 33%
}

class Chefao extends Inimigo {
  late int hpMaxOriginal;
  FaseChefao faseAtual = FaseChefao.normal;
  int ataqueBaseOriginal = 0;
  int modificadorDanoFase = 0;
  int turnosNaFase = 0;
  bool usouAtaqueEspecial = false;

  Chefao({
    String nome = 'Rei da Masmorra',
    int hpMax = 150,
    int danoBase = 12,
  }) : super(
    nome: nome,
    hpMax: hpMax,
    ataque: danoBase,
    descricao: 'O senhor ancião da masmorra. Seus olhos brilham com malevolência.',
  ) {
    hpMaxOriginal = hpMax;
    ataqueBaseOriginal = danoBase;
  }

  void atualizarFase() {
    final percentualHp = (hp / hpMax) * 100;

    if (percentualHp > 66) {
      if (faseAtual != FaseChefao.normal) {
        print('├─ O Rei permanece em controle...');
      }
      faseAtual = FaseChefao.normal;
      modificadorDanoFase = 0;
    } else if (percentualHp > 33) {
      if (faseAtual != FaseChefao.furia) {
        print('\n[FÚRIA] O Rei entra em FÚRIA! Seus ataques se tornam devastadores!');
        print('   Dano aumentado em 50%!\n');
      }
      faseAtual = FaseChefao.furia;
      modificadorDanoFase = (ataqueBaseOriginal * 0.5).toInt();
    } else {
      if (faseAtual != FaseChefao.desesperado) {
        print('\n[DESESPERADO] Enfraquecido e DESESPERADO, o Rei tenta um ataque final!');
        print('   Chance de ataque crítico aumenta!\n');
      }
      faseAtual = FaseChefao.desesperado;
      modificadorDanoFase = (ataqueBaseOriginal * 0.75).toInt();
    }

    turnosNaFase++;
  }

  @override
  void executarTurno(Jogador jogador) {
    atualizarFase();

    print('\n--- Turno do $nome ---');

    if (faseAtual == FaseChefao.desesperado &&
        !usouAtaqueEspecial &&
        Random().nextDouble() < 0.4) {
      _ataqueEspecial(jogador);
      usouAtaqueEspecial = true;
    } else {
      final dano = ataqueBaseOriginal + modificadorDanoFase;
      final variacao = (dano * 0.15).toInt();
      final danoFinal =
          dano - variacao + Random().nextInt(variacao * 2);

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

  void _ataqueEspecial(Jogador jogador) {
    print('\n* O Rei invoca um poder ancestral!');
    print('   > RAIO ANCESTRAL atinge ${jogador.nome}!');

    final danoCritico = (ataqueBaseOriginal * 2.5).toInt();
    jogador.sofrerDano(danoCritico);

    print('   Dano crítico: $danoCritico!');
  }

  String descreverStatus() {
    final percentualHp = (hp / hpMax) * 100;
    final faseTexto = switch (faseAtual) {
      FaseChefao.normal => '[OK] Normal',
      FaseChefao.furia => '[FÚRIA] Fúria (+50% dano)',
      FaseChefao.desesperado => '[CRITICO] Desesperado (+crítico)',
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

## Sistema de GameState

O jogo em qualquer momento está num estado: explorando, combatendo, na loja, em pausa, morto, vencedor. A classe `GerenciadorEstadoJogo` rastreia isto com um enum `EstadoJogo`. Permite mudanças de estado e até voltar ao anterior. Isto é útil: você pode pausar (mudando para estado "pausado"), depois voltar, e tudo fica coerente.

```dart
// lib/estado_jogo.dart

enum EstadoJogo {
  menuPrincipal,
  explorando,
  combatendo,
  naLoja,
  subindoNivel,
  pausado,
  vitoria,
  derrota,
}

class GerenciadorEstadoJogo {
  EstadoJogo estadoAtual = EstadoJogo.menuPrincipal;
  EstadoJogo estadoAnterior = EstadoJogo.menuPrincipal;

  void mudarPara(EstadoJogo novoEstado) {
    estadoAnterior = estadoAtual;
    estadoAtual = novoEstado;
    print('\n→ Estado: ${estadoAtual.name}');
  }

  void voltarPara() {
    final temp = estadoAtual;
    estadoAtual = estadoAnterior;
    estadoAnterior = temp;
  }

  bool em(EstadoJogo estado) => estadoAtual == estado;
}
```

## Progressão de Andares

A classe `GerenciadorAndares` encapsula toda a lógica de dificuldade por andar. Para cada andar (0-4), define: quanto HP extra os inimigos têm, quanto ataque extra ganham, quais tipos aparecem, que itens podem cair, descrição narrativa. Isto permite controle fino da curva de dificuldade.

```dart
// lib/gerenciador_andares.dart

class GerenciadorAndares {
  int andarAtual = 0;
  final int andarFinal = 4;

  (int hpBonus, int ataqueBonus, List<String> inimigos)
      configurarAndar(int numero) {
    return switch (numero) {
      0 => (hpBonus: 0, ataqueBonus: 0, inimigos: ['zumbi']),
      1 => (
        hpBonus: 10,
        ataqueBonus: 2,
        inimigos: ['zumbi', 'lobo'],
      ),
      2 => (
        hpBonus: 20,
        ataqueBonus: 4,
        inimigos: ['lobo', 'esqueleto'],
      ),
      3 => (
        hpBonus: 35,
        ataqueBonus: 6,
        inimigos: ['esqueleto', 'orc'],
      ),
      4 => (
        hpBonus: 60,
        ataqueBonus: 10,
        inimigos: ['chefao'],
      ),
      _ => (
        hpBonus: 100,
        ataqueBonus: 15,
        inimigos: ['chefao'],
      ),
    };
  }

  List<String> itensPorAndar(int numero) {
    return switch (numero) {
      0 => ['pocaoVida', 'pocaoVida'],
      1 => ['pocaoVida', 'pocaoVida', 'espadaFerro'],
      2 => ['pocaoVida', 'espadaAco', 'escudoAco'],
      3 => ['pocaoVida', 'espadaRunada', 'armaduraPesada'],
      4 => [],
      _ => [],
    };
  }

  String descreverAndar(int numero) {
    return switch (numero) {
      0 => 'Você entra nas masmorras. O ar é frio e úmido. Lodo cobre o chão.',
      1 => 'O segundo andar é mais rochoso. Você ouve ecos de criaturas.',
      2 => 'Aqui, ossos cobrem o solo. A magia é palpável.',
      3 => 'Este é o andar da perdição. Auras malignas fluem.',
      4 =>
        'Você entra numa câmara colossal. No centro, um trono antigo. E nele, ELE.',
      _ => 'Um lugar estranho na masmorra.',
    };
  }

  bool ehAndarDoChefe() => andarAtual == andarFinal;
  bool ehUltimoAndar() => andarAtual >= andarFinal;
}
```

## Telas de Vitória e Derrota

Quando o jogo termina, você não quer apenas "FIM". Quer celebração (vitória) ou epitáfio (derrota). A classe `TelaFimJogo` renderiza telas bonitas que mostram suas estatísticas: nível final, turnos vividos, inimigos derrotados, ouro coletado. Isto torna o fim memorável.

```dart
// lib/tela_fim_jogo.dart

class TelaFimJogo {
  final Jogador jogador;
  final int andarAlcancado;
  final int totalTurnos;
  final int totalInimigosDefeitos;
  final int totalOuroColetado;
  final bool vitoria;

  TelaFimJogo({
    required this.jogador,
    required this.andarAlcancado,
    required this.totalTurnos,
    required this.totalInimigosDefeitos,
    required this.totalOuroColetado,
    required this.vitoria,
  });

  void mostrar() {
    if (vitoria) {
      _mostrarVitoria();
    } else {
      _mostrarDerrota();
    }
  }

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
    print('Herói:          ${jogador.nome}');
    print('Nível Final:    ${jogador.nivel}');
    print('HP:             ${jogador.hp}/${jogador.hpMax}');
    print('Ataque:         ${jogador.ataque}');
    print('');
    print('CAMPANHA');
    print('─' * 55);
    print('Andares Explorados:   $andarAlcancado / 5');
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

  void _mostrarDerrota() {
    print('');
    print('DERROTA AMARGA');
    print('');
    print('Você caiu nas sombras da masmorra, derrotado');
    print('pelas forças que nela habitam.');
    print('');
    print('EPITÁFIO');
    print('═' * 55);
    print('');
    print('Aqui jaz ${jogador.nome}');
    print('Um herói de nível ${jogador.nivel}');
    print('');
    print('Caiu no andar $andarAlcancado');
    print('Derrotou $totalInimigosDefeitos inimigos');
    print('Coletou $totalOuroColetado ouro');
    print('Viveu por $totalTurnos turnos');
    print('');
    print('═' * 55);
    print('');
    print('Nem toda jornada resulta em glória.');
    print('Mas sua tentativa é lembrada.');
    print('');
  }
}
```

## Desafios da Masmorra

**Desafio 26.1. Fúria do Chefão.** O Chefão Antigo entra em fúria quando ferido. Mude suas fases: de 66%/33% de HP para 75%/50% (fica furioso por mais tempo, mais ameaçador). Implemente em `atualizarFase()`. Teste: lute contra o boss, veja quando muda de fase. Sente-se mais desafiador? Dica: números importam na tensão.

**Desafio 26.2. Legiões da Sombra.** Ao entrar em fúria, o Chefão chama dois espectros: "Invocação de Sombras". Crie dois inimigos sombrios temporários (30% do HP do boss) que atacam ao seu lado. Implemente em `_ataqueEspecial()`. Teste: quando combater o boss na fase 2, dois aliados dele aparecem. Você precisa decidir: mata os espectros ou ataca o boss? Estratégia. Dica: use `List<Inimigo>` para gerenciar temporários.

**Desafio 26.3. A Arena Final.** O boss não aparece num andar procedural aleatório. Implemente `gerarSalaBoss()` que retorna uma única sala grande (80x20) limpa, só com chão. Boss no centro da sala, você spawna perto da entrada. Vasto, árido, épico. Implemente no gerador de andar final. Teste: descida ao boss deve se sentir diferente—solitário, vazio, apenas você vs ele. Dica: preencha com `Tile.chao`, coloque boss em coordenada específica.

**Desafio 26.4. O Prêmio da Vitória.** Ao derrotar o Chefão, você ganha a "Espada Ancestral Lendária" que aumenta Ataque em +10 permanentemente. Implemente na sequência de vitória: após mensagem de vitória, adicione item ao inventário. Teste: derrote o boss, veja o item aparecer. Você fica significativamente mais forte. Recompensa épica pelo sacrifício. Dica: `Jogador.adicionarItem()` com um objeto especial.

**Desafio 26.5. (Desafio): Jogo se Adapta a Você.** O jogo aprende de suas deficiências. Cada vitória aumenta dificuldade (+1, máx +5): inimigos 15% mais fortes. Cada derrota reduz (-1, mín -5): inimigos 15% mais fracos. Multiplicador final: `1.0 + (nível × 0.15)`. Isso cria curva de aprendizado: iniciante que morre muito fica em -5 (75% força), veterano vitorioso sobe em +5 (175% força). Teste 10 partidas com diferentes habilidades, veja dificuldade convergir. Dica: salve `nivelDificuldade` junto com stats.

**Boss Final 26.6. Troféu de Glória.** Na tela de vitória, mostre epopeia completa: (1) Tempo total (em minutos), (2) Ratio vitórias (inimigos derrotados / inimigos encontrados), (3) Andares conquistados, (4) Item mais valioso equipado. Crie uma bela tela ASCII que celebra a vitória com números. Teste: vitória deve ser momento satisfatório com reconhecimento dos seus feitos. Dica: rastreie `tempoInicio`, `inimigosDerrota dos`, `totalInimigos` durante o jogo.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- `GerenciadorAndares` configura dificuldade, inimigos e itens por andar
- `Chefao` é um inimigo especial com fases (normal → fúria → desesperado)
- `EstadoJogo` enum rastreia o estado global do jogo
- Transição dinâmica: descida de andares com geração procedural
- Telas de Game Over: vitória e derrota com estatísticas completas
- Integração: combate contra boss é o clímax de todo o sistema

Seu jogo agora é uma campanha completa: você começa fraco, progride através de 5 andares, enfrenta o chefe e vence ou perde. Isto é um verdadeiro roguelike.

## Dica Profissional

::: dica
Curva de dificuldade é arte, não ciência. Teste com diferentes grupos: iniciantes devem passar no andar 1-2 no primeiro dia, intermediários devem chegar ao andar 3-4, veteranos devem chegar ao boss. Reúna dados: em que andar a maioria morre? Quanto tempo leva? O boss é muito fácil ou muito difícil?
:::

## Próximo Capítulo

No Capítulo 27, vamos integrar tudo em uma versão completa e jogável do roguelike, com menu principal, seleção de dificuldade, e a jornada completa pronta para compartilhar.

***
