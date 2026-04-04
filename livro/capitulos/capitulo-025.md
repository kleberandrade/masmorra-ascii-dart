# Capítulo 25 - Progressão: XP, Níveis e Habilidades

> *Toda aventura é um percurso de transformação: você começa fraco, indefeso, um principiante perdido nas sombras da masmorra. Mas a cada inimigo derrotado, a cada andar descido, você cresce. Seu corpo fica mais forte. Seus reflexos agudizam. Você aprende magias novas e poderosas. Este é o coração da progressão; sem ela, um roguelike é apenas morte repetida. Com ela, é uma jornada épica de ascensão.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Criar um sistema de XP e níveis com fórmulas quadráticas
- Implementar `TabelaProgressao` com curva de levantamento balanceada
- Aumentar HP máximo e ataque ao subir de nível
- Desbloquear habilidades especiais em marcos de nível (nível 3, nível 5)
- Implementar a classe `Habilidade` com execução dinâmica
- Integrar o event system para notificações de *level up*
- Escalar inimigos por andar (mais difíceis conforme você desce)
- Demonstrar um combate completo com progressão visível

Ao final, seu jogo terá verdadeira sensação de progresso como em *Chrono Trigger* ou *Elden Ring*.

## O Sistema de Progressão

Progressão é o motor emocional do *roguelike*. Sem progressão visível, cada morte sente-se como desperdício puro. Com progressão bem calibrada, cada morte é aprendizado: você chegou mais longe, ficou mais forte, desbloqueou habilidades. O jogador *sente* que está melhorando.

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

**Por quê essa fórmula?** Porque no início você ganha níveis rápido (diversão imediata: nível 1→2 precisa só 50 XP). Mas depois desacelera exponencialmente (desafio: nível 20 precisa 19,000 XP). É balanceado para *roguelikes*: iniciantes não desistem rapidamente, veteranos têm meta de longo prazo.

## TabelaProgressao: A Tabela Mestre

A progressão por XP segue uma fórmula. Você escolhe qual. Aqui usamos quadrática (`n² × 50`), que significa: nível 1 precisa 0 XP, nível 2 precisa 50, nível 3 precisa 200, nível 4 precisa 450. A curva sobe rápido; é difícil alcançar nível 20.

A classe `TabelaProgressao` é a base de todo o sistema. Ela centraliza toda a matemática: cálculo de XP necessário, progresso em percentual, bônus por nível, XP por tipo de inimigo. Todos os números importantes vivem aqui. Isso significa que balancear o jogo é tão simples quanto mudar um número em um único arquivo—nada espalhado, tudo em um lugar.

Por quê design assim? Porque em desenvolvimento profissional, se a progressão estivesse espalhada em 10 classes diferentes, ajustar dificuldade seria um pesadelo. Centralizar dados em uma "tabela mestre" é um padrão universal em game design: databases no Skyrim, spreadsheets na Supercell, tudo segue esse princípio.

```dart
// lib/tabela_progressao.dart

/// Define a curva de experiência e recompensas de nível
class TabelaProgressao {
  /// Fórmula: XP necessário para alcançar um nível
  int xpParaNivel(int nivel) {
    if (nivel <= 1) return 0;
    final n = nivel - 1;
    // ← fórmula quadrática: nível sobe mais caro com tempo
    return n * n * 50;
  }

  /// XP necessário para ir DO nível atual AO próximo
  int xpNecessarioParaProximoNivel(int nivelAtual) {
    final proximoNivel = nivelAtual + 1;
    // ← diferença entre níveis
    return xpParaNivel(proximoNivel) - xpParaNivel(nivelAtual);
  }

  /// Quanto XP falta (ou quantos pontos você passou)
  int xpRestanteParaProximo(int nivelAtual, int xpAtual) {
    final xpDoNivelAtual = xpParaNivel(nivelAtual);
    final xpDoProximo = xpParaNivel(nivelAtual + 1);
    // ← progresso dentro da janela
    final xpNaJanela = xpAtual - xpDoNivelAtual;
    final janelaNecessaria = xpDoProximo - xpDoNivelAtual;
    return janelaNecessaria - xpNaJanela;  // ← quanto resta
  }

  /// Progresso em percentual (0-100) para próximo nível
  int percentualProgresso(int nivelAtual, int xpAtual) {
    if (nivelAtual >= 20) return 100;  // ← cap no nível máximo
    final xpDoNivelAtual = xpParaNivel(nivelAtual);
    final xpDoProximo = xpParaNivel(nivelAtual + 1);
    final xpNaJanela = xpAtual - xpDoNivelAtual;
    final janelaNecessaria = xpDoProximo - xpDoNivelAtual;
    // ← conversão para 0-100%
    return ((xpNaJanela / janelaNecessaria) * 100).toInt();
  }

  int bonusHPPorNivel() => 10;
  int bonusAtaquePorNivel() => 2;
  int nivelMaximo() => 20;

  int xpPorInimigo(String tipoInimigo) {
    return switch (tipoInimigo) {
      'zumbi' => 15,          // ← fracos = pouco XP
      'lobo' => 30,           // ← médios = médio XP
      'esqueleto' => 50,      // ← fortes = mais XP
      'orc' => 75,            // ← muito fortes = muito XP
      _ => 10,                // ← padrão seguro
    };
  }
}
```

**Saída esperada ao criar TabelaProgressao:**

```text
// Exemplo de uso:
var tabela = TabelaProgressao();
print(tabela.xpParaNivel(5));  // 800
print(tabela.xpNecessarioParaProximoNivel(3));  // 250
print(tabela.percentualProgresso(2, 150));  // ~75%
print(tabela.xpPorInimigo('lobo'));  // 30
```

## Integração com Jogador

Agora estendemos a classe `Jogador` para incluir XP e nível. O jogador não é mais estático; pode ganhar XP, subir de nível, desbloquear habilidades. Isso é crucial: em um *roguelike*, o herói deve *crescer*. Cada *level up* é psicologicamente importante: HP aumenta, ataque aumenta, nova habilidade desbloqueada. O jogador *vê* e *sente* progresso.

O design é simples: quando `ganharXp()` é chamado, o método `verificarNivel()` checa automaticamente se deve haver *level up*. Se sim, aumenta HP máximo (restaurando HP completamente), aumenta ataque, desbloqueia habilidades, e dispara um evento. Tudo em um único lugar bem organizado.

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
    tabela = TabelaProgressao();  // ← carrega tabela de progressão
    eventos = BarramentoEventos<EventoJogo>();
  }

  /// Ganha XP e verifica se sobe de nível
  void ganharXp(int quantidade) {
    xp += quantidade;  // ← acumula XP
    print('$nome ganhou $quantidade XP (Total: $xp)');
    verificarNivel();  // ← checa se deve fazer *level up*
  }

  /// Verifica se o jogador deve subir de nível
  void verificarNivel() {
    final proximoNivel = nivel + 1;
    final xpNecessario = tabela.xpParaNivel(proximoNivel);

    // ← loop: pode fazer múltiplos *level ups* em um ganho grande de XP
    while (xp >= xpNecessario && nivel < tabela.nivelMaximo()) {
      nivel++;
      maxHp += tabela.bonusHPPorNivel();
      // ← restaura HP completamente (recompensa psicológica)
      hp = maxHp;
      ataque += tabela.bonusAtaquePorNivel();

      print('\nLEVEL UP! $nome agora é nível $nivel!');
      final bHp = tabela.bonusHPPorNivel();
      final bAtk = tabela.bonusAtaquePorNivel();
      print('   HP máximo: +$bHp (agora $maxHp)');
      print('   Ataque: +$bAtk (agora $ataque)');
      print('   HP restaurado!\n');

      // ← dispara evento para UI/sistema de logging
      eventos.dispara(EventoNivel(
        nivelAnterior: nivel - 1,
        nivelNovo: nivel,
        bonus: '+${tabela.bonusHPPorNivel()} HP, '
            '+${tabela.bonusAtaquePorNivel()} ATK',
      ));

      // ← pode desbloquear novas habilidades
      _desbloquearHabilidades();
    }
  }

  /// Mostra barra de progresso até próximo nível
  String barraProgresso() {
    final percent = tabela.percentualProgresso(nivel, xp);
    final blocos = (percent / 10).toInt();  // ← 10 blocos no total
    final cheios = '#' * blocos;
    final vazios = '-' * (10 - blocos);
    return '$cheios$vazios $percent%';  // ← ex: "####------ 40%"
  }

  void _desbloquearHabilidades() {
    // Será preenchido em "Parte 5"
  }
}
```

**Saída esperada ao ganhar XP:**

```text
Guerreiro ganhou 30 XP (Total: 80)

Guerreiro ganhou 50 XP (Total: 130)

LEVEL UP! Guerreiro agora é nível 2!
   HP máximo: +10 (agora 60)
   Ataque: +2 (agora 7)
   HP restaurado!
```

**Nota técnica:** O método `verificarNivel()` usa um loop `while`, não `if`. Por quê? Porque se o jogador ganhar muito XP de uma vez (ex: 500 XP), deve fazer múltiplos *level ups* simultaneamente. O loop garante isso. A condição `xp >= xpNecessario` avalia constantemente até não haver mais níveis a subir.

## Sistema de Habilidades

Habilidades são ações especiais que você desbloqueia ao subir de nível. Cada habilidade é uma classe que herda de `Habilidade` (abstrata). Implementa `executar()` que faz algo único: *golpe forte* (2x dano), *curar* (restaura 30% HP), *ataque rápido* (dois ataques).

O padrão *Strategy* é perfeito aqui: cada habilidade é uma estratégia diferente de combate. Você guarda uma lista de habilidades desbloqueadas, e durante o combate, o jogador escolhe qual executar (alternativa a "atacar normalmente"). Isso torna o combate tático: diferentes situações pedem diferentes habilidades.

**Design:** Cada habilidade conhece seu nível requerido, nome, descrição. No `executar()`, faz algo único. Isto torna fácil adicionar novas habilidades: crie uma classe nova, herde de `Habilidade`, implemente `executar()`. Pronto. Extensibilidade sem modificar código existente.

```dart
// lib/habilidade.dart

/// Interface abstrata para todas as habilidades
abstract class Habilidade {
  final String nome;
  final String descricao;
  final int nivelRequerido;

  Habilidade({
    required this.nome,
    required this.descricao,
    required this.nivelRequerido,
  });

  /// Executa a habilidade. Retorna true se bem-sucedida.
  /// ← cada subclasse implementa sua própria lógica
  bool executar(Jogador jogador, {Inimigo? alvo});

  /// Formata para exibição (ex: menu de habilidades)
  String formato() {
    // ← display padronizado
    return '[$nome] (Nív $nivelRequerido) - $descricao';
  }
}

/// Habilidade: Golpe Forte
/// Desbloqueado no nível 3
/// Dano: 2× o ataque normal
/// Dano concentrado num ataque (menos golpes, mais fortes)
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

    // ← 2x dano do ataque normal
    final danoDuplicado = jogador.ataque * 2;
    print('\n${jogador.nome} executa um GOLPE FORTE!');
    print('   Dano: $danoDuplicado');

    return alvo.sofrerDano(danoDuplicado);
  }
}

/// Habilidade: Curar
/// Desbloqueado no nível 5
/// Efeito: +30% do HP máximo
/// Estratégia: defesa (recupera saúde em vez de atacar)
class Curar extends Habilidade {
  Curar()
      : super(
        nome: 'Curar',
        descricao: 'Recupera 30% do HP máximo. Gasta 1 turno.',
        nivelRequerido: 5,
      );

  @override
  bool executar(Jogador jogador, {Inimigo? alvo}) {
    // ← 30% do HP máximo
    final curaQuantidade = (jogador.maxHp * 0.3).toInt();
    final hpAnterior = jogador.hp;
    // ← limita a HP máximo
    jogador.hp = (jogador.hp + curaQuantidade).clamp(0, jogador.maxHp);
    final curaReal = jogador.hp - hpAnterior;

    print('\n${jogador.nome} invoca CURAR!');
    print('   Recuperou $curaReal HP');

    return true;
  }
}

/// Habilidade: Ataque Rápido (nível 7)
/// Ataque 2x de 60% cada (total = 120% em um turno)
/// Estratégia: múltiplos ataques (chance de acertar mesmo se um falhar)
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

    // ← primeiro ataque (60%)
    final dano1 = (jogador.ataque * 0.6).toInt();
    // ← segundo ataque (60%)
    final dano2 = (jogador.ataque * 0.6).toInt();

    print('\n${jogador.nome} executa ATAQUE RÁPIDO!');
    print('   Golpe 1: $dano1 de dano');
    alvo.sofrerDano(dano1);

    // ← inimigo já morreu, pula golpe 2
    if (!alvo.estaVivo) return true;

    print('   Golpe 2: $dano2 de dano');
    return alvo.sofrerDano(dano2);
  }
}
```

**Saída esperada ao executar habilidades:**

```text
Guerreiro executa um GOLPE FORTE!
   Dano: 14

Guerreiro invoca CURAR!
   Recuperou 18 HP

Guerreiro executa ATAQUE RÁPIDO!
   Golpe 1: 4 de dano
   Golpe 2: 4 de dano
```

**Por que não apenas aumentar ataque permanentemente?** Porque habilidades criam *momentos emocionantes*. Um *level up* com nova habilidade é mais memorável que +2 de ataque silencioso. Além disso, habilidades criam tática em combate: "Devo curar agora ou tentar matar o inimigo rápido com Golpe Forte?"

## Desbloquear Habilidades

De volta ao `Jogador`. Quando você sobe de nível, o método `_desbloquearHabilidades()` é chamado. Se atingiu nível 3 e não tem "Golpe Forte", aprende. E assim por diante. Isto significa habilidades aparecem *naturalmente*, marcando marcos na progressão. O jogador sempre sabe: "No nível 5 desbloqueio Curar".

Esse design é intencional: marcos claros mantêm o jogador engajado. "Faltam 100 XP para nível 5 e a habilidade Curar" é uma meta psicológica poderosa.

```dart
class Jogador extends Entidade {
  final List<Habilidade> habilidades = [];

  void _desbloquearHabilidades() {
    switch (nivel) {
      case 3:
        // ← nível 3: desbloqueio Golpe Forte
        if (!habilidades.any((h) => h.nome == 'Golpe Forte')) {
          habilidades.add(GolpeForte());
          print('* Você aprendeu a habilidade: Golpe Forte!');
        }
        break;
      case 5:
        // ← nível 5: desbloqueio Curar
        if (!habilidades.any((h) => h.nome == 'Curar')) {
          habilidades.add(Curar());
          print('* Você aprendeu a habilidade: Curar!');
        }
        break;
      case 7:
        // ← nível 7: desbloqueio Ataque Rápido
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
      // ← exibe cada habilidade com índice para seleção em combate
      print('[$i] ${habilidades[i].formato()}');
    }
    print('');
  }
}
```

**Saída esperada ao subir para nível 3:**

```text
LEVEL UP! Guerreiro agora é nível 3!
   HP máximo: +10 (agora 70)
   Ataque: +2 (agora 7)
   HP restaurado!
* Você aprendeu a habilidade: Golpe Forte!
```

**Nota técnica:** O método `habilidades.any()` verifica se uma habilidade com esse nome já existe. Por quê? Para evitar duplicatas. Se o jogador respecificar seu nível (em um cheat, por exemplo), não quer aprender a mesma habilidade duas vezes.

## Desafios da Masmorra

**Desafio 25.1. A Escalada Interminável.** Conforme você sobe de nível, custa cada vez mais. Mude a fórmula: em vez de `n² × 50`, use `n³ × 10` (cúbica). Calcule manualmente: nível 3 custa quanto antes vs depois? (Antes: 200 XP; Depois: 200 XP, coincidência!). A progressão fica muito mais lenta em níveis altos (realista para um *roguelike*). Implemente e teste níveis 1-5: os custos aumentam dramaticamente? Dica: use `n * n * n * 10` no cálculo. Compare as duas fórmulas visualmente em um gráfico.

**Desafio 25.2. Três Caminhos do Guerreiro.** Você pode treinar para ser recruta (rápido), normal (balanceado), ou veterano (lento mas forte). Crie enum `Dificuldade { recruta, normal, veterano }` e campo em `Jogador`. Modifique `ganharXp()`: recruta ganha 1.5x (treina rápido), normal 1.0x, veterano 0.5x (mas deve ganhar mais estatísticas). Teste: que caminho progride mais rápido? Qual é mais difícil? Dica: multiplicadores revelam trade-offs.

**Desafio 25.3. Barra de Progresso Épica.** Você quer saber exatamente onde está na progressão. Implemente `mostrarProgressoDetalhado()`: "Nível 4 ████████░░ 80% | 240/300 XP". Calcule quantos blocos cheios versus vazios. Mostre também: (1) XP atual no nível, (2) XP necessário total, (3) percentual. Teste ganhar XP e ver barra crescer. Satisfação visual. Dica: calcule percentual como `(xpAtual / xpProximo) * 100`.

**Desafio 25.4. O Paladim Nível 10.** Ao atingir nível 10, você desbloqueia uma habilidade especial: "Cura em Grupo". Crie uma classe `CuraEmGrupo extends Habilidade` que cura 50% do HP máximo E reduz dano sofrido em 30% no próximo turno. Implemente: `bool podeExecutar()` (nível >= 10), `void executar()` (aplica cura, marca redutor). Teste: chegue a nível 10, use a habilidade, veja HP restaurado. Dica: sealed classes para habilidades.

**Desafio 25.5. (Desafio): Distribuição de Pontos de Poder.** Cada level up dá 2 "Pontos de Habilidade". Você investe: (+1 HP por ponto), (+1 Ataque por ponto), (+1 Defesa por 3 pontos = reduz 5% dano). Crie um menu interativo: "Ganhou 2 pontos. Digite: 'hp', 'ataque' ou 'defesa'". Teste: suba 5 níveis, distribua 10 pontos total, veja suas stats aumentarem diferente baseado em sua escolha. Mestre estrategista. Dica: `pontosHabilidade` é persistente até usar.

**Boss Final 25.6. Invencibilidade Temporária.** Se você derrotar 5 inimigos seguidos sem sofrer dano, você entra em "Fúria Perfeita" e ganha +50% XP na próxima vitória. Rastreie um `streakSemDano` que incrementa ao vencer sem dano recebido, reseta se sofrer dano. Teste: derrote 5 inimigos limpos (evite dano), vença mais um e ganhe 50% XP extra. Falhe uma vez? Streak reseta. Incentiva jogo agressivo e sem defeitos. Dica: `streakSemDano` é um getter que retorna quantos inimigos consecutivos venceu sem dano.

## Comparação: Antes vs. Depois

### Antes (Sem Sistema de Progressão)

Cada combate é igual. Você ataca, inimigo ataca. Vitória sente-se sorte. Derrota sente-se injusta. Sem meta, sem *level up*, sem recompensa psicológica.

```dart
// Inimigo genérico, nunca muda
class Zumbi extends Inimigo {
  Zumbi() : super(nome: 'Zumbi', hpMax: 10, ataque: 2);
}

// Jogador estático
class Jogador extends Entidade {
  // Nada de XP, nada de níveis
}
```

### Depois (Com Progressão)

Cada vitória é palpável. Você sobe de nível, ganha habilidades, fica mais forte. Desafios antigos ficam triviais. Novos desafios esperam. Há sempre uma meta.

```dart
// Jogador dinâmico que cresce
jogador.ganharXp(30);  // Subir de nível? Novo poder desbloqueado?
print(jogador.barraProgresso());  // Vejo meu progresso visualmente
```

**Impacto psicológico:** Com progressão, o jogador joga "mais uma partida" para alcançar nível 5. Sem progressão, abandona após morte uma.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- `TabelaProgressao` com fórmula quadrática cria crescimento natural
- *Level up* aumenta HP máximo, ataque, restaura HP completamente
- Habilidades são classes especializadas que você desbloqueia em marcos (padrão *Strategy*)
- Integração em combate: habilidades são opções estratégicas alternativas a "atacar"
- Escalação: inimigos ficam progressivamente mais fortes (próximos capítulos)
- Event system: notificações limpas quando coisas importantes acontecem

Seu jogo agora tem verdadeira sensação de progresso. Você não é mais um guerreiro estático; é um herói em ascensão que aprende magias, fica mais forte, enfrenta desafios crescentes.

**Um sistema de progressão bem balanceado é a diferença entre um jogo que você joga uma vez e um jogo que você não consegue parar de jogar.**

## Dica Profissional

::: dica
**Dica do Mestre:** Balanceamento é iterativo, nunca definitivo. A fórmula que escolhemos (`n² × 50`) é um ponto de partida. Quando começar a testar: meça tempo entre níveis (deve levar ~5 minutos?), registre stats, ajuste constantemente. Mudar para `n² × 40` ou `n² × 60` é trivial. Teste várias versões. O número certo só aparece com testes reais de jogadores. Dados sempre vencem intuição. Uma sheet com as três primeiras fórmulas, testadas por três pessoas diferentes, revela a verdade rapidamente.
:::

## Próximo Capítulo

No Capítulo 26 vamos criar múltiplos andares com dificuldade crescente, um boss final épico, e a estrutura de vitória/derrota que torna o jogo uma verdadeira campanha.

***
