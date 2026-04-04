/// Capítulo 37 - Síntese: O Jogo Completo, Polido e Pronto
/// Boss Final 37.5: Padrão MVC (Model-View-Controller)
///
/// Refatora o jogo em uma arquitetura MVC profissional:
/// - Model: EstadoJogo, lógica pura (sem UI)
/// - View: TelaAscii, renderização pura
/// - Controller: LoopJogo, orquestração e entrada
///
/// Permite jogar via CLI ou via API HTTP sem modificar a lógica.

import 'dart:io';

/// ═══════════════════════════════════════════════════════════════════════
/// MODEL: Lógica pura, independente de UI
/// ═══════════════════════════════════════════════════════════════════════

/// Representa um personagem
class Personagem {
  String nome;
  int hp;
  int hpMax;
  int ataque;
  int defesa;
  int nivel;
  int xp;

  Personagem({
    required this.nome,
    required this.hpMax,
    required this.ataque,
    required this.defesa,
    required this.nivel,
  })  : hp = hpMax,
        xp = 0;

  bool estaVivo() => hp > 0;

  void tomarDano(int dano) {
    hp -= dano.clamp(0, hpMax);
  }

  void ganharXp(int xp) {
    this.xp += xp;
    if (this.xp >= 100) {
      nivel++;
      this.xp = 0;
      ataque += 2;
      hpMax += 10;
      hp = hpMax;
    }
  }

  @override
  String toString() =>
      '$nome (Nv.$nivel | $hp/$hpMax HP | XP: $xp | ATK: $ataque | DEF: $defesa)';
}

/// Estado completo do jogo
class EstadoJogo {
  Personagem jogador;
  int andarAtual;
  int turnos;
  List<String> log;

  EstadoJogo({
    required this.jogador,
    this.andarAtual = 1,
  })  : turnos = 0,
        log = [];

  void registrarEvento(String evento) {
    log.add('[$turnos] $evento');
  }

  void iniciarTurno() {
    turnos++;
  }

  bool jogo_terminou() => !jogador.estaVivo();
}

/// ═══════════════════════════════════════════════════════════════════════
/// VIEW: Renderização pura
/// ═══════════════════════════════════════════════════════════════════════

class TelaAscii {
  static const int largura = 70;

  /// Limpa a tela
  void limpar() {
    print('\x1B[2J\x1B[0;0H');
  }

  /// Renderiza cabeçalho do jogo
  void renderizarCabecalho(EstadoJogo estado) {
    print('═' * largura);
    print('MASMORRA ASCII - Andar ${estado.andarAtual} | Turno: ${estado.turnos}');
    print('═' * largura);
  }

  /// Renderiza status do jogador
  void renderizarStatus(EstadoJogo estado) {
    final j = estado.jogador;
    print('\n${j.nome}');
    print('HP: [${_barraHP(j.hp, j.hpMax)}] ${j.hp}/${j.hpMax}');
    print('Nível: ${j.nivel} | XP: ${j.xp}/100 | Ataque: ${j.ataque} | Defesa: ${j.defesa}');
    print('');
  }

  /// Renderiza log de eventos recentes
  void renderizarLog(EstadoJogo estado) {
    print('─ Log de Eventos ─');
    final eventos = estado.log.length > 5
        ? estado.log.sublist(estado.log.length - 5)
        : estado.log;

    for (final evento in eventos) {
      print('  $evento');
    }
    print('');
  }

  /// Renderiza tela completa
  void renderizar(EstadoJogo estado) {
    limpar();
    renderizarCabecalho(estado);
    renderizarStatus(estado);
    renderizarLog(estado);
  }

  /// Barra de HP visual
  String _barraHP(int atual, int max) {
    final preenchido = (atual / max * 20).toInt();
    final vazio = 20 - preenchido;
    final pct = (atual / max * 100).toInt();
    return '█' * preenchido + '░' * vazio + ' $pct%';
  }

  /// Menu de ações
  void mostrarMenu() {
    print('─ Ações ─');
    print('  [a] Atacar');
    print('  [c] Curar');
    print('  [s] Sair');
    print('');
  }
}

/// ═══════════════════════════════════════════════════════════════════════
/// CONTROLLER: Orquestração (entrada e saída)
/// ═══════════════════════════════════════════════════════════════════════

class LoopJogo {
  final EstadoJogo estado;
  final TelaAscii tela;

  LoopJogo({required this.estado, required this.tela});

  /// Processa um comando do jogador
  void processarComando(String comando) {
    switch (comando.toLowerCase()) {
      case 'a':
        executarAtaque();
      case 'c':
        executarCura();
      case 's':
        print('Saindo...');
        break;
      default:
        estado.registrarEvento('Comando inválido: $comando');
    }
  }

  /// Executa ataque contra inimigo fictício
  void executarAtaque() {
    final dano = 8 + (estado.jogador.ataque ~/ 5);
    estado.registrarEvento('${estado.jogador.nome} ataca e causa $dano de dano!');
    estado.jogador.ganharXp(25);

    // Inimigo contra-ataca
    final danoRecebido = 5;
    estado.jogador.tomarDano(danoRecebido);
    estado.registrarEvento('Inimigo contra-ataca! ${estado.jogador.nome} toma $danoRecebido de dano');
  }

  /// Executa cura
  void executarCura() {
    const cura = 15;
    final hpAntes = estado.jogador.hp;
    estado.jogador.hp += cura;
    if (estado.jogador.hp > estado.jogador.hpMax) {
      estado.jogador.hp = estado.jogador.hpMax;
    }
    final curaReal = estado.jogador.hp - hpAntes;
    estado.registrarEvento('${estado.jogador.nome} se cura por $curaReal HP');
  }

  /// Loop principal do jogo
  void executar() {
    while (!estado.jogo_terminou()) {
      estado.iniciarTurno();
      tela.renderizar(estado);
      tela.mostrarMenu();

      stdout.write('> ');
      final comando = stdin.readLineSync() ?? 's';

      processarComando(comando);

      if (comando.toLowerCase() == 's') {
        break;
      }
    }

    // Fim de jogo
    tela.renderizar(estado);
    if (estado.jogador.estaVivo()) {
      print('✓ Vitória! Parabéns ${estado.jogador.nome}!');
    } else {
      print('✗ Derrota! ${estado.jogador.nome} caiu...');
    }
    print('');
  }
}

/// ═══════════════════════════════════════════════════════════════════════
/// Backend Alternativo: API (sem UI)
/// ═══════════════════════════════════════════════════════════════════════

class BackendAPI {
  final EstadoJogo estado;

  BackendAPI({required this.estado});

  /// Processa um comando via API (retorna JSON simulado)
  Map<String, dynamic> processarAcao(String acao) {
    estado.iniciarTurno();

    switch (acao) {
      case 'atacar':
        final dano = 8 + (estado.jogador.ataque ~/ 5);
        estado.registrarEvento('Ataque! Causa $dano de dano');
        estado.jogador.ganharXp(25);
        return {'sucesso': true, 'mensagem': 'Ataque executado', 'dano': dano};

      case 'curar':
        const cura = 15;
        estado.jogador.hp += cura;
        if (estado.jogador.hp > estado.jogador.hpMax) {
          estado.jogador.hp = estado.jogador.hpMax;
        }
        estado.registrarEvento('Curado por $cura');
        return {'sucesso': true, 'mensagem': 'Curado', 'cura': cura};

      default:
        return {'sucesso': false, 'mensagem': 'Ação inválida'};
    }
  }

  /// Retorna estado atual como JSON
  Map<String, dynamic> obterEstado() {
    return {
      'jogador': {
        'nome': estado.jogador.nome,
        'hp': estado.jogador.hp,
        'hpMax': estado.jogador.hpMax,
        'nivel': estado.jogador.nivel,
        'xp': estado.jogador.xp,
        'ataque': estado.jogador.ataque,
        'defesa': estado.jogador.defesa,
      },
      'andar': estado.andarAtual,
      'turnos': estado.turnos,
      'vivo': estado.jogador.estaVivo(),
    };
  }
}

/// ═══════════════════════════════════════════════════════════════════════
/// MAIN: Demonstração do padrão MVC
/// ═══════════════════════════════════════════════════════════════════════

void main() {
  print('╔════════════════════════════════════════════╗');
  print('║     PADRÃO MVC - MODEL-VIEW-CONTROLLER     ║');
  print('║       Capítulo 37 - Boss Final             ║');
  print('╚════════════════════════════════════════════╝\n');

  // Cria o modelo (estado puro)
  final jogador = Personagem(
    nome: 'Aventureiro',
    hpMax: 50,
    ataque: 10,
    defesa: 3,
    nivel: 1,
  );
  final estado = EstadoJogo(jogador: jogador);

  print('Escolha modo:');
  print('  [1] CLI Interativa (com renderização)');
  print('  [2] API (sem UI, apenas dados)');
  stdout.write('> ');
  final opcao = stdin.readLineSync() ?? '1';

  if (opcao == '1') {
    // Modo CLI com UI
    print('\n--- Modo CLI com Renderização ---\n');
    final tela = TelaAscii();
    final jogo = LoopJogo(estado: estado, tela: tela);
    jogo.executar();
  } else {
    // Modo API (sem UI)
    print('\n--- Modo API (sem UI) ---\n');
    final api = BackendAPI(estado: estado);

    // Simula algumas ações
    print('Estado inicial: ${api.obterEstado()}');
    print('');

    print('Ação 1: atacar');
    var resultado = api.processarAcao('atacar');
    print('  Resultado: $resultado');
    print('');

    print('Ação 2: curar');
    resultado = api.processarAcao('curar');
    print('  Resultado: $resultado');
    print('');

    print('Estado final: ${api.obterEstado()}');
    print('');
    print('A mesma lógica funciona em ambos os modos!');
  }

  print('\n✓ Padrão MVC permite múltiplos frontends (CLI, API, UI gráfica)');
  print('  sem duplicar lógica de jogo. Código profissional!');
}
