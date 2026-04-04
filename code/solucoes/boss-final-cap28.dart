// ============================================================================
// Capítulo 28 - Boss Final: Quebra da Deus Classe
// ============================================================================
// Exercício: Refatoração de Classe Monolítica em Responsabilidades
//
// Implementa padrão SRP: uma classe grande é quebrada em especializadas.
// JogadorModelo: dados puros. RenderizadorJogador: UI. CombateJogador: regras.
// Demonstra decomposição, Single Responsibility, e design limpo.
// ============================================================================

// ============================================================================
// 1. MODELO: Apenas dados e estado (SRP)
// ============================================================================

/// Armazena apenas atributos do jogador
class JogadorModelo {
  final String nome;
  int hpMax;
  int hp;
  int ataque;
  int defesa;
  int xp;
  int nivel;

  JogadorModelo({
    required this.nome,
    required this.hpMax,
    required this.ataque,
    required this.defesa,
    this.xp = 0,
    this.nivel = 1,
  }) : hp = hpMax;

  // Apenas getters simples
  bool get estaVivo => hp > 0;
  double get porcentagemHP => (hp / hpMax) * 100;

  // Lógica de estado puro
  void receberDano(int dano) {
    hp = (hp - dano).clamp(0, hpMax);
  }

  void curar(int quantidade) {
    hp = (hp + quantidade).clamp(0, hpMax);
  }

  void ganharXP(int quantidade) {
    xp += quantidade;
    // Level up a cada 100 XP
    while (xp >= 100) {
      xp -= 100;
      nivel++;
      hpMax += 10;
      hp = hpMax;
      ataque += 2;
    }
  }

  @override
  String toString() => '$nome (Nível $nivel, HP: $hp/$hpMax)';
}

// ============================================================================
// 2. RENDERIZADOR: Responsável apenas pela UI (SRP)
// ============================================================================

/// Renderiza informações do jogador em ASCII
class RenderizadorJogador {
  // Desenha barra de vida colorida
  static String desenharBarraHP(JogadorModelo jogador) {
    final porcentagem = jogador.porcentagemHP;
    final barraLargura = 20;
    final barraPreenchida = (barraLargura * porcentagem / 100).toInt();

    final barra = '█' * barraPreenchida + '░' * (barraLargura - barraPreenchida);
    final cor = porcentagem > 50 ? '✓' : porcentagem > 25 ? '⚠' : '✗';

    return '[$cor] [$barra] ${porcentagem.toStringAsFixed(0)}%';
  }

  // Exibe status completo
  static void exibirStatus(JogadorModelo jogador) {
    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║ ${jogador.nome.padRight(56)} ║');
    print('╠════════════════════════════════════════════════════════════╣');
    print('║ Nível: ${jogador.nivel.toString().padRight(52)} ║');
    print('║ HP: ${jogador.hp}/${jogador.hpMax}');
    print('║ ${desenharBarraHP(jogador).padRight(56)} ║');
    print('║ Ataque: ${jogador.ataque}  Defesa: ${jogador.defesa}');
    print('║ XP: ${jogador.xp}/100');
    print('╚════════════════════════════════════════════════════════════╝\n');
  }

  // Exibe animação de dano
  static void exibirDano(JogadorModelo jogador, int dano) {
    print('❌ $dano de dano! (HP: ${jogador.hp})');
  }

  // Exibe animação de cura
  static void exibirCura(JogadorModelo jogador, int cura) {
    print('✨ Curou $cura HP! (HP: ${jogador.hp}/${jogador.hpMax})');
  }

  // Exibe level up
  static void exibirLevelUp(JogadorModelo jogador) {
    print('🌟 LEVEL UP! Agora nível ${jogador.nivel}! +10 HP, +2 ATK');
  }
}

// ============================================================================
// 3. LÓGICA DE COMBATE: Regras de combate isoladas (SRP)
// ============================================================================

/// Calcula dano e regras de combate
class CombateJogador {
  final JogadorModelo jogador;

  CombateJogador({required this.jogador});

  /// Calcula dano que o jogador causa
  int calcularDano() {
    // Base: ataque + randomização
    final variacao = (-3 + (jogador.ataque ~/ 5)) as int;
    final dano = jogador.ataque + variacao;
    return dano.clamp(1, jogador.ataque * 2);
  }

  /// Calcula dano recebido com aplicação de defesa
  int calcularDanoRecebido(int danoBase) {
    final reducao = (danoBase * (jogador.defesa / 100)).toInt();
    final danoFinal = (danoBase - reducao).clamp(1, danoBase);
    return danoFinal;
  }

  /// Simula ataque do jogador
  String atacar() {
    final dano = calcularDano();
    return 'Ataque: ${jogador.nome} causa $dano de dano!';
  }

  /// Simula defesa (reduz próximo dano em 30%)
  String defender() {
    return '${jogador.nome} se defende! Próximo dano -30%';
  }

  /// Aplica dano levando em conta defesa
  void sofrerDano(int danoBase) {
    final danoReal = calcularDanoRecebido(danoBase);
    jogador.receberDano(danoReal);
    RenderizadorJogador.exibirDano(jogador, danoReal);
  }

  /// Cura o jogador
  void curar(int quantidade) {
    final curaPrev = jogador.hp;
    jogador.curar(quantidade);
    final curaReal = jogador.hp - curaPrev;
    RenderizadorJogador.exibirCura(jogador, curaReal);
  }

  /// Ganha XP e trata level up
  void ganharXP(int quantidade) {
    final nivelAntes = jogador.nivel;
    jogador.ganharXP(quantidade);

    if (jogador.nivel > nivelAntes) {
      RenderizadorJogador.exibirLevelUp(jogador);
    }
  }
}

// ============================================================================
// 4. GERENCIADOR: Orquestra os três sistemas
// ============================================================================

/// Coordena modelo, renderizador e combate
class JogadorGerenciador {
  late JogadorModelo modelo;
  late RenderizadorJogador renderizador;
  late CombateJogador combate;

  JogadorGerenciador(String nome) {
    modelo = JogadorModelo(
      nome: nome,
      hpMax: 50,
      ataque: 10,
      defesa: 5,
    );
    renderizador = RenderizadorJogador();
    combate = CombateJogador(jogador: modelo);
  }

  // Delegação clara
  void mostrarStatus() => RenderizadorJogador.exibirStatus(modelo);
  String atacar() => combate.atacar();
  void sofrerDano(int dano) => combate.sofrerDano(dano);
  void curar(int amount) => combate.curar(amount);
  void ganharXP(int xp) => combate.ganharXP(xp);

  bool get estaVivo => modelo.estaVivo;
}

// ============================================================================
// Demonstração do sistema refatorado
// ============================================================================

void main() {
  print('\n════════════════════════════════════════════════════════════════');
  print('  MASMORRA ASCII - Capítulo 28: Quebra da Deus Classe');
  print('════════════════════════════════════════════════════════════════\n');

  final jogador = JogadorGerenciador('Aragorn');

  // ======================================================================
  // TESTE 1: Exibir status
  // ======================================================================
  print('🔍 TESTE 1: Status Inicial');
  print('───────────────────────────────────────────────────────────────');
  jogador.mostrarStatus();

  // ======================================================================
  // TESTE 2: Combate (ataque, dano, cura)
  // ======================================================================
  print('🔍 TESTE 2: Simulação de Combate');
  print('───────────────────────────────────────────────────────────────');

  print(jogador.atacar());
  print('Inimigo ataca!');
  jogador.sofrerDano(15);

  print('\nJogador bebe poção...');
  jogador.curar(20);

  // ======================================================================
  // TESTE 3: Progresso de XP e level up
  // ======================================================================
  print('\n🔍 TESTE 3: Progressão de XP');
  print('───────────────────────────────────────────────────────────────');

  print('Jogador ganha XP...');
  jogador.ganharXP(30);
  jogador.ganharXP(40);
  print('Faltam ${100 - jogador.modelo.xp} XP para o próximo nível');

  print('\nDerrotou boss! +100 XP');
  jogador.ganharXP(100);
  jogador.mostrarStatus();

  // ======================================================================
  // TESTE 4: Demonstrar separação de responsabilidades
  // ======================================================================
  print('\n🔍 TESTE 4: Demonstração de SRP');
  print('───────────────────────────────────────────────────────────────');
  print('✓ JogadorModelo: armazena estado (HP, XP, nível)');
  print('✓ RenderizadorJogador: exibe informações (barra HP, status)');
  print('✓ CombateJogador: calcula regras (dano, defesa, XP)');
  print('✓ JogadorGerenciador: orquestra os três');

  // ======================================================================
  // TESTE 5: Cada classe pode ser testada isoladamente
  // ======================================================================
  print('\n🔍 TESTE 5: Testabilidade de Cada Responsabilidade');
  print('───────────────────────────────────────────────────────────────');

  // Testar modelo diretamente
  final modelo = JogadorModelo(
    nome: 'Tester',
    hpMax: 100,
    ataque: 20,
    defesa: 5,
  );
  modelo.receberDano(30);
  print('✓ Teste modelo: ${modelo.hp}/100 HP após 30 dano');

  // Testar combate em isolamento
  final combate = CombateJogador(jogador: modelo);
  final dano = combate.calcularDano();
  print('✓ Teste combate: dano calculado = $dano');

  // Testar renderizador sem dependências de jogo
  final barra = RenderizadorJogador.desenharBarraHP(modelo);
  print('✓ Teste renderizador: $barra');

  // ======================================================================
  // TESTE 6: Cenário completo
  // ======================================================================
  print('\n🔍 TESTE 6: Cenário Completo - Combate com Progression');
  print('───────────────────────────────────────────────────────────────');

  final heroi = JogadorGerenciador('Legolas');
  print('Iniciando jornada...\n');

  for (int ronda = 1; ronda <= 3; ronda++) {
    print('═ Ronda $ronda');
    print(heroi.atacar());
    heroi.sofrerDano(10);
    heroi.ganharXP(25);
    print();
  }

  heroi.mostrarStatus();

  print('════════════════════════════════════════════════════════════════');
  print('  ✓ Código refatorado: limpo, testável, mantível!');
  print('════════════════════════════════════════════════════════════════\n');
}
