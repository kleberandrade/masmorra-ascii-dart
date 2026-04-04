# Capítulo 25 - Progressão: XP, Níveis e Habilidades

> *Toda aventura é um percurso de transformação: você começa fraco, indefeso, um principiante perdido nas sombras da masmorra. Mas a cada inimigo derrotado, a cada andar descido, você cresce. Seu corpo fica mais forte. Seus reflexos agudizam. Você aprende magias novas e poderosas. Este é o coração da progressão; sem ela, um roguelike é apenas morte repetida. Com ela, é uma jornada épica de ascensão.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Criar um sistema de XP e níveis com fórmulas quadráticas
- Implementar `TabelaProgressao` com curva de levantamento balanceada
- Aumentar HP máximo e ataque ao subir de nível
- Desbloquear habilidades especiais em marcos de nível (nível 3, nível 5)
- Implementar a classe `Habilidade` com execução dinâmica
- Integrar o event system para notificações de level up
- Escalar inimigos por andar (mais difíceis conforme você desce)
- Demonstrar um combate completo com progressão visível

Ao final, seu jogo terá verdadeira sensação de progresso como em Chrono Trigger ou Elden Ring.

## O Sistema de Progressão

Antes de código, visualize o crescimento:

```text
Nível 1:   0 XP
Nível 2:  50 XP (1 × 1 × 50)
Nível 3:  200 XP (2 × 2 × 50), +150 XP necessário
Nível 4:  450 XP (3 × 3 × 50), +250 XP necessário
Nível 5:  800 XP (4 × 4 × 50), +350 XP necessário
Nível 10: 4.950 XP (9 × 9 × 50). A curva sobe rapidamente
```

Fórmula: `xpParaNivel(n) = n² × 50` (quadrática)

Por quê? Porque no início você ganha níveis rápido (diversão), mas depois desacelera (desafio). É balanceado para roguelikes.

## TabelaProgressao: A Tabela Mestre

A progressão por XP segue uma fórmula. Você escolhe qual. Aqui usamos quadrática (`n² × 50`), que significa: nível 1 precisa 0 XP, nível 2 precisa 50, nível 3 precisa 200, nível 4 precisa 450. A curva sobe rápido; é difícil alcançar nível 20.

A classe `TabelaProgressao` centraliza toda a matemática: cálculo de XP necessário, progresso em percentual, bônus por nível, XP por tipo de inimigo. Todos os números importantes vivem aqui.

```dart
// lib/tabelaProgressao.dart

/// Define a curva de experiência e recompensas de nível
class TabelaProgressao {
  /// Fórmula: XP necessário para alcançar um nível
  int xpParaNivel(int nivel) {
    if (nivel <= 1) return 0;
    final n = nivel - 1;
    return n * n * 50;
  }

  /// XP necessário para ir DO nível atual AO próximo
  int xpNecessarioParaProximoNivel(int nivelAtual) {
    final proximoNivel = nivelAtual + 1;
    return xpParaNivel(proximoNivel) - xpParaNivel(nivelAtual);
  }

  /// Quanto XP falta (ou quantos pontos você passou)
  int xpRestanteParaProximo(int nivelAtual, int xpAtual) {
    final xpDoNivelAtual = xpParaNivel(nivelAtual);
    final xpDoProximo = xpParaNivel(nivelAtual + 1);
    final xpNaJanela = xpAtual - xpDoNivelAtual;
    final janelaNecessaria = xpDoProximo - xpDoNivelAtual;
    return janelaNecessaria - xpNaJanela;
  }

  /// Progresso em percentual (0-100) para próximo nível
  int percentualProgresso(int nivelAtual, int xpAtual) {
    if (nivelAtual >= 20) return 100;
    final xpDoNivelAtual = xpParaNivel(nivelAtual);
    final xpDoProximo = xpParaNivel(nivelAtual + 1);
    final xpNaJanela = xpAtual - xpDoNivelAtual;
    final janelaNecessaria = xpDoProximo - xpDoNivelAtual;
    return ((xpNaJanela / janelaNecessaria) * 100).toInt();
  }

  int bonusHPPorNivel() => 10;
  int bonusAtaquePorNivel() => 2;
  int nivelMaximo() => 20;

  int xpPorInimigo(String tipoInimigo) {
    return switch (tipoInimigo) {
      'zumbi' => 15,
      'lobo' => 30,
      'esqueleto' => 50,
      'orc' => 75,
      _ => 10,
    };
  }
}
```

## Integração com Jogador

Modifica `Jogador` para incluir XP e nível. Agora o jogador não é mais estático; pode ganhar XP, subir de nível, desbloquear habilidades. Cada vez que ganha XP, verifica se deve subir de nível. Se sim, aumenta HP e ataque, restaura saúde, desbloqueia habilidades, dispara evento.

```dart
// lib/jogador.dart

class Jogador extends Entidade {
  int nivel = 1;
  int xp = 0;

  late final TabelaProgressao tabela;
  late final BarramentoEventos<EventoJogo> eventos;

  Jogador({
    required String nome,
    int maxHp = 50,
    int ataque = 5,
  }) : super(nome: nome, hpMax: maxHp, ataque: ataque) {
    tabela = TabelaProgressao();
    eventos = BarramentoEventos<EventoJogo>();
  }

  /// Ganha XP e verifica se sobe de nível
  void ganharXp(int quantidade) {
    xp += quantidade;
    print('$nome ganhou $quantidade XP (Total: $xp)');
    verificarNivel();
  }

  /// Verifica se o jogador deve subir de nível
  void verificarNivel() {
    final proximoNivel = nivel + 1;
    final xpNecessario = tabela.xpParaNivel(proximoNivel);

    while (xp >= xpNecessario && nivel < tabela.nivelMaximo()) {
      nivel++;
      maxHp += tabela.bonusHPPorNivel();
      hp = maxHp;
      ataque += tabela.bonusAtaquePorNivel();

      print('\nLEVEL UP! $nome agora é nível $nivel!');
      print('   HP máximo: +${tabela.bonusHPPorNivel()} (agora $maxHp)');
      print('   Ataque: +${tabela.bonusAtaquePorNivel()} (agora $ataque)');
      print('   HP restaurado!\n');

      eventos.dispara(EventoNivel(
        nivelAnterior: nivel - 1,
        nivelNovo: nivel,
        bonus: '+${tabela.bonusHPPorNivel()} HP, '
            '+${tabela.bonusAtaquePorNivel()} ATK',
      ));

      _desbloquearHabilidades();
    }
  }

  /// Mostra barra de progresso até próximo nível
  String barraProgresso() {
    final percent = tabela.percentualProgresso(nivel, xp);
    final blocos = (percent / 10).toInt();
    final cheios = '#' * blocos;
    final vazios = '-' * (10 - blocos);
    return '$cheios$vazios $percent%';
  }

  void _desbloquearHabilidades() {
    // Será preenchido em "Parte 5"
  }
}
```

## Sistema de Habilidades

Habilidades são ações especiais que você desbloqueia ao subir de nível. Cada habilidade é uma classe que herda de `Habilidade` (abstrata). Implementa `executar()` que faz algo único: golpe forte (2x dano), curar (restaura 30% HP), ataque rápido (dois ataques).

O padrão Strategy é usado aqui: cada habilidade é uma estratégia diferente. Você guarda uma lista delas, e em combate, você escolhe qual executar.

```dart
// lib/habilidade.dart

abstract class Habilidade {
  final String nome;
  final String descricao;
  final int nivelRequerido;

  Habilidade({
    required this.nome,
    required this.descricao,
    required this.nivelRequerido,
  });

  bool executar(Jogador jogador, {Inimigo? alvo});

  String formato() {
    return '[$nome] (Nív $nivelRequerido) - $descricao';
  }
}

/// Habilidade: Golpe Forte
/// Desbloqueado no nível 3
/// Dano: 2× o ataque normal
class GolpeForte extends Habilidade {
  GolpeForte()
      : super(
        nome: 'Golpe Forte',
        descricao: 'Ataque de 2x dano. Gasta 1 turno.',
        nivelRequerido: 3,
      );

  @override
  bool executar(Jogador jogador, {Inimigo? alvo}) {
    if (alvo == null) return false;

    final danoDuplicado = jogador.ataque * 2;
    print('\n${jogador.nome} executa um GOLPE FORTE!');
    print('   Dano: $danoDuplicado');

    return alvo.sofrerDano(danoDuplicado);
  }
}

/// Habilidade: Curar
/// Desbloqueado no nível 5
/// Efeito: +30% do HP máximo
class Curar extends Habilidade {
  Curar()
      : super(
        nome: 'Curar',
        descricao: 'Recupera 30% do HP máximo. Gasta 1 turno.',
        nivelRequerido: 5,
      );

  @override
  bool executar(Jogador jogador, {Inimigo? alvo}) {
    final curaQuantidade = (jogador.maxHp * 0.3).toInt();
    final hpAnterior = jogador.hp;
    jogador.hp = (jogador.hp + curaQuantidade).clamp(0, jogador.maxHp);
    final curaReal = jogador.hp - hpAnterior;

    print('\n${jogador.nome} invoca CURAR!');
    print('   Recuperou $curaReal HP');

    return true;
  }
}

/// Habilidade: Ataque Rápido (nível 7)
/// Ataque 2x de 60% cada
class AtaqueRapido extends Habilidade {
  AtaqueRapido()
      : super(
        nome: 'Ataque Rápido',
        descricao: 'Dois ataques rápidos de 60% cada. Gasta 1 turno.',
        nivelRequerido: 7,
      );

  @override
  bool executar(Jogador jogador, {Inimigo? alvo}) {
    if (alvo == null) return false;

    final dano1 = (jogador.ataque * 0.6).toInt();
    final dano2 = (jogador.ataque * 0.6).toInt();

    print('\n${jogador.nome} executa ATAQUE RÁPIDO!');
    print('   Golpe 1: $dano1 de dano');
    alvo.sofrerDano(dano1);

    if (!alvo.estaVivo) return true;

    print('   Golpe 2: $dano2 de dano');
    return alvo.sofrerDano(dano2);
  }
}
```

## Desbloquear Habilidades

De volta ao `Jogador`. Quando você sobe de nível, o método `_desbloquearHabilidades()` é chamado. Se atingiu nível 3 e não tem "Golpe Forte", aprende. E assim por diante. Isto significa habilidades aparecem naturalmente, marcando marcos na progressão.

```dart
class Jogador extends Entidade {
  final List<Habilidade> habilidades = [];

  void _desbloquearHabilidades() {
    switch (nivel) {
      case 3:
        if (!habilidades.any((h) => h.nome == 'Golpe Forte')) {
          habilidades.add(GolpeForte());
          print('* Você aprendeu a habilidade: Golpe Forte!');
        }
        break;
      case 5:
        if (!habilidades.any((h) => h.nome == 'Curar')) {
          habilidades.add(Curar());
          print('* Você aprendeu a habilidade: Curar!');
        }
        break;
      case 7:
        if (!habilidades.any((h) => h.nome == 'Ataque Rápido')) {
          habilidades.add(AtaqueRapido());
          print('* Você aprendeu a habilidade: Ataque Rápido!');
        }
        break;
    }
  }

  void mostrarHabilidades() {
    if (habilidades.isEmpty) {
      print('Nenhuma habilidade desbloqueada ainda.');
      return;
    }

    print('\nHABILIDADES');
    print('─' * 30);
    for (int i = 0; i < habilidades.length; i++) {
      print('[$i] ${habilidades[i].formato()}');
    }
    print('');
}
```

## Desafios da Masmorra

**Desafio 25.1. A Escalada Interminável.** Conforme você sobe de nível, custa cada vez mais. Mude a fórmula: em vez de `n² × 50`, use `n³ × 10` (cúbica). Calcule manualmente: nível 3 custa quanto antes vs depois? A progressão fica muito mais lenta (realista para um roguelike). Implemente e teste níveis 1-5: os custos aumentam dramaticamente? Dica: use `n * n * n * 10` no cálculo.

**Desafio 25.2. Três Caminhos do Guerreiro.** Você pode treinar para ser recruta (rápido), normal (balanceado), ou veterano (lento mas forte). Crie enum `Dificuldade { recruta, normal, veterano }` e campo em `Jogador`. Modifique `ganharXP()`: recruta ganha 1.5x (treina rápido), normal 1.0x, veterano 0.5x (mas deve ganhar mais estatísticas). Teste: que caminho progride mais rápido? Qual é mais difícil? Dica: multiplicadores revelam trade-offs.

**Desafio 25.3. Barra de Progresso Épica.** Você quer saber exatamente onde está na progressão. Implemente `mostrarProgressoDetalhado()`: "Nível 4 ████████░░ 80% | 240/300 XP". Calcule quantos blocos cheios versus vazios. Mostre também: (1) XP atual no nível, (2) XP necessário total, (3) percentual. Teste ganhar XP e ver barra crescer. Satisfação visual. Dica: calcule percentual como `(xpAtual / xpProximo) * 100`.

**Desafio 25.4. O Paladim Nível 10.** Ao atingir nível 10, você desbloqueia uma habilidade especial: "Cura em Grupo". Crie uma classe `CuraEmGrupo extends Habilidade` que cura 50% do HP máximo E reduz dano sofrido em 30% no próximo turno. Implemente: `bool podeExecutar()` (nível >= 10), `void executar()` (aplica cura, marca redutor). Teste: chegue a nível 10, use a habilidade, veja HP restaurado. Dica: sealed classes para habilidades.

**Desafio 25.5. (Desafio): Distribuição de Pontos de Poder.** Cada level up dá 2 "Pontos de Habilidade". Você investe: (+1 HP por ponto), (+1 Ataque por ponto), (+1 Defesa por 3 pontos = reduz 5% dano). Crie um menu interativo: "Ganhou 2 pontos. Digite: 'hp', 'ataque' ou 'defesa'". Teste: suba 5 níveis, distribua 10 pontos total, veja suas stats aumentarem diferente baseado em sua escolha. Mestre estrategista. Dica: `pontosHabilidade` é persistente até usar.

**Boss Final 25.6. Invencibilidade Temporária.** Se você derrotar 5 inimigos seguidos sem sofrer dano, você entra em "Fúria Perfeita" e ganha +50% XP na próxima vitória. Rastreie um `streakSemDano` que incrementa ao vencer sem dano recebido, reseta se sofrer dano. Teste: derrote 5 inimigos limpos (evite dano), vença mais um e ganhe 50% XP extra. Falhe uma vez? Streak reseta. Incentiva jogo agressivo e sem defeitos. Dica: `streakSemDano` é um getter que retorna quantos inimigos consecutivos venceu sem dano.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- `TabelaProgressao` com fórmula quadrática cria crescimento natural
- Level up aumenta HP máximo, ataque, restaura HP completamente
- Habilidades são classes especializadas que você desbloqueia em marcos
- Integração em combate: habilidades são opções equivalentes a "atacar"
- Escalação: inimigos ficam progressivamente mais fortes
- Event system: notificações limpas quando coisas importantes acontecem

Seu jogo agora tem verdadeira sensação de progresso. Você não é mais um guerreiro estático; é um herói em ascensão que aprende magias, fica mais forte, enfrenta desafios crescentes.

## Dica Profissional

::: dica
Balanceamento é iterativo. A fórmula que escolhemos (`n² × 50`) é um ponto de partida. Quando começar a testar: meça tempo entre níveis, registre stats, ajuste constantemente. Mudar para `n² × 40` ou `n² × 60` é trivial. Teste várias versões. O número certo só aparece com testes reais de jogadores. Dados sempre vencem intuição.
:::

## Próximo Capítulo

No Capítulo 26 vamos criar múltiplos andares com dificuldade crescente, um boss final épico, e a estrutura de vitória/derrota que torna o jogo uma verdadeira campanha.

***
