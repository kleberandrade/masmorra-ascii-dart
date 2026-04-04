// Capítulo 20 - Boss Final: IA de Inimigos (Movimentação)
// Descrição: Inimigos perseguem o jogador se estiverem dentro do FOV.
// Senão, caminham aleatoriamente. Implementa pathfinding simples (Manhattan).

import 'dart:math';

class Posicao {
  int x;
  int y;

  Posicao(this.x, this.y);

  int distanciaManhattan(Posicao outra) {
    return (x - outra.x).abs() + (y - outra.y).abs();
  }

  Posicao copiar() => Posicao(x, y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Posicao && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Inimigo {
  final String nome;
  final String simbolo;
  Posicao posicao;
  final int hpMax;
  int hpAtual;
  final Random random;

  Inimigo({
    required this.nome,
    required this.simbolo,
    required Posicao posicao,
    required this.hpMax,
    Random? random,
  })  : posicao = posicao,
        hpAtual = hpMax,
        random = random ?? Random();

  bool estaVivo() => hpAtual > 0;

  // Movementação: retorna nova posição (ou mesma se não consegue se mover)
  Posicao moverIA(Posicao posicaoJogador, int raioVistaSentidoPersonalizado) {
    // Verificar se jogador está no raio de visão
    if (posicao.distanciaManhattan(posicaoJogador) <= raioVistaSentidoPersonalizado) {
      // Perseguir: mover na direção do jogador
      return _perseguir(posicaoJogador);
    } else {
      // Patrulhar: andar aleatoriamente
      return _patrulhar();
    }
  }

  Posicao _perseguir(Posicao alvo) {
    final novaPosicao = posicao.copiar();

    // Tentar mover na direção do alvo (Manhattan)
    final dx = alvo.x - posicao.x;
    final dy = alvo.y - posicao.y;

    // Preferência: mover no eixo com maior distância
    if (dx.abs() > dy.abs()) {
      // Mover horizontalmente
      novaPosicao.x += dx > 0 ? 1 : -1;
    } else {
      // Mover verticalmente
      novaPosicao.y += dy > 0 ? 1 : -1;
    }

    return novaPosicao;
  }

  Posicao _patrulhar() {
    final novaPosicao = posicao.copiar();
    final direcao = random.nextInt(4);

    switch (direcao) {
      case 0:
        novaPosicao.y--;
      case 1:
        novaPosicao.y++;
      case 2:
        novaPosicao.x--;
      case 3:
        novaPosicao.x++;
    }

    return novaPosicao;
  }

  void tomarDano(int dano) {
    hpAtual = (hpAtual - dano).clamp(0, hpMax);
  }

  @override
  String toString() => '$nome ($simbolo) - HP: $hpAtual/$hpMax em ${posicao.x}, ${posicao.y}';
}

class SimuladorCombate {
  final List<Inimigo> inimigos;
  final Posicao posicaoJogador;
  final int raioVistaSentido = 10;

  int turno = 0;
  List<String> logMarcacao = [];

  SimuladorCombate({
    required this.inimigos,
    required this.posicaoJogador,
  });

  void executarTurnoInimigos() {
    turno++;
    logMarcacao.clear();

    logMarcacao.add('--- Turno $turno ---');

    for (final inimigo in inimigos) {
      if (!inimigo.estaVivo()) continue;

      final novaPosicao = inimigo.moverIA(posicaoJogador, raioVistaSentido);
      final distancia = inimigo.posicao.distanciaManhattan(posicaoJogador);

      // Validar movimento (simples: sem paredes, sem limites)
      if (novaPosicao.x >= 0 && novaPosicao.x < 30 && novaPosicao.y >= 0 && novaPosicao.y < 15) {
        inimigo.posicao = novaPosicao;
      }

      // Log: persegue ou patrulha?
      if (distancia <= raioVistaSentido) {
        logMarcacao.add('  ${inimigo.nome}: PERSEGUINDO jogador (dist: $distancia)');
      } else {
        logMarcacao.add('  ${inimigo.nome}: patrulhando');
      }

      // Verificar contato (distância 1 = adjacente)
      if (inimigo.posicao.distanciaManhattan(posicaoJogador) <= 1) {
        logMarcacao.add('    ⚔️ ${inimigo.nome} ATACOU o jogador!');
      }
    }
  }

  void simularTurnos(int numTurnos) {
    print('=== Boss Final Cap 20: IA de Inimigos ===\n');
    print('Jogador: ${posicaoJogador.x}, ${posicaoJogador.y}');
    print('Inimigos: ${inimigos.length}');
    print('Raio de Visão: $raioVistaSentido tiles\n');

    for (int i = 0; i < numTurnos; i++) {
      executarTurnoInimigos();

      // Imprimir log
      for (final msg in logMarcacao) {
        print(msg);
      }
      print();
    }

    // Estado final
    print('--- ESTADO FINAL ---');
    for (final inimigo in inimigos) {
      print('${inimigo.nome}: ${inimigo.posicao.x}, ${inimigo.posicao.y}');
      print('  HP: ${inimigo.hpAtual}/${inimigo.hpMax}');
    }
  }

  void renderizarMapa() {
    final mapa = List.generate(15, (_) => List.filled(30, '.'));

    // Desenhar inimigos
    for (final inimigo in inimigos) {
      if (inimigo.estaVivo()) {
        mapa[inimigo.posicao.y][inimigo.posicao.x] = inimigo.simbolo;
      }
    }

    // Desenhar jogador
    mapa[posicaoJogador.y][posicaoJogador.x] = '@';

    // Imprimir
    print('--- MAPA ---');
    for (int y = 0; y < 15; y++) {
      for (int x = 0; x < 30; x++) {
        stdout.write(mapa[y][x]);
      }
      stdout.writeln();
    }
  }
}

void main() {
  // Criar inimigos
  final inimigo1 = Inimigo(
    nome: 'Goblin',
    simbolo: 'G',
    posicao: Posicao(20, 7),
    hpMax: 30,
  );

  final inimigo2 = Inimigo(
    nome: 'Lobo',
    simbolo: 'L',
    posicao: Posicao(5, 10),
    hpMax: 50,
  );

  final inimigo3 = Inimigo(
    nome: 'Orc',
    simbolo: 'O',
    posicao: Posicao(25, 3),
    hpMax: 60,
  );

  final jogador = Posicao(15, 7);

  final simulador = SimuladorCombate(
    inimigos: [inimigo1, inimigo2, inimigo3],
    posicaoJogador: jogador,
  );

  // Simular 10 turnos
  simulador.simularTurnos(10);

  print('\n--- MAPA FINAL ---');
  simulador.renderizarMapa();

  print('\n✓ Demonstração: Inimigos perseguem o jogador quando visível,');
  print('  caso contrário, patrulham aleatoriamente!\n');
}
