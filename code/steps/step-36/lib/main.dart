import 'modelos/inimigo.dart';
import 'padroes/estado_ia.dart';

void main() {
  print('=== DEMONSTRAÇÃO: State Machine (FSM) Pattern ===\n');

  // ============ CRIANDO INIMIGO COM FSM ============
  print('--- Criando inimigo com máquina de estados ---\n');

  var lobo = Inimigo(
    nome: 'Lobo Alfa',
    hpMax: 50,
    ataque: 7,
    defesa: 2,
    estadoAtual: Patrulhando([
      'Posição A',
      'Posição B',
      'Posição C',
    ]),
  );

  print('${lobo.nome} HP: ${lobo.hpAtual}/${lobo.hpMax}');
  print('Estado inicial: ${lobo.estadoAtual.nome}\n');

  // Simular um alvo
  var jogador = Inimigo(
    nome: 'Jogador',
    hpMax: 100,
    ataque: 8,
    defesa: 1,
    estadoAtual: Patrulhando([]),
  );

  // ============ TRANSIÇÕES DE ESTADO ============
  print('--- Simulando transições de estado ---\n');

  print('TURNO 1: Lobo em patrulha');
  print('  Estado: ${lobo.estadoAtual.nome}');
  var acao1 = lobo.obterProximaAcao(jogador, null);
  print('  Ação: $acao1\n');

  print('TURNO 2: Alerta (avistou o jogador)');
  lobo.estadoAtual = Alerta();
  print('  Estado: ${lobo.estadoAtual.nome}');
  var acao2 = lobo.obterProximaAcao(jogador, null);
  print('  Ação: $acao2\n');

  print('TURNO 3: Perseguindo (confirmou a ameaça)');
  lobo.estadoAtual = Perseguindo();
  print('  Estado: ${lobo.estadoAtual.nome}');
  var acao3 = lobo.obterProximaAcao(jogador, null);
  print('  Ação: $acao3\n');

  print('TURNO 4: Atacando (em alcance do jogador)');
  lobo.estadoAtual = Atacando();
  print('  Estado: ${lobo.estadoAtual.nome}');
  var acao4 = lobo.obterProximaAcao(jogador, null);
  print('  Ação: $acao4\n');

  // ============ SIMULAÇÃO COMPLETA DE COMBATE ============
  print('--- Simulação completa de combate com transições automáticas ---\n');

  var goblin = Inimigo(
    nome: 'Goblin Vermelha',
    hpMax: 35,
    ataque: 5,
    defesa: 0,
    estadoAtual: Patrulhando([
      'Caverna 1',
      'Caverna 2',
      'Caverna 3',
    ]),
  );

  print('${goblin.nome} iniciando em patrulha. HP: ${goblin.hpAtual}/${goblin.hpMax}');
  print('--- Sequência de eventos ---\n');

  // Turno 1: Patrulhando
  print('TURNO 1:');
  print('  Estado: ${goblin.estadoAtual.nome}');
  print('  HP: ${goblin.hpAtual}');
  print('  Ação: ${goblin.obterProximaAcao(jogador, null)}');
  print();

  // Turno 2: Alerta
  goblin.estadoAtual = Alerta();
  print('TURNO 2: (Avistado o jogador)');
  print('  Estado: ${goblin.estadoAtual.nome}');
  print('  HP: ${goblin.hpAtual}');
  print('  Ação: ${goblin.obterProximaAcao(jogador, null)}');
  print();

  // Turno 3: Perseguindo
  goblin.estadoAtual = Perseguindo();
  print('TURNO 3: (Iniciando perseguição)');
  print('  Estado: ${goblin.estadoAtual.nome}');
  print('  HP: ${goblin.hpAtual}');
  print('  Ação: ${goblin.obterProximaAcao(jogador, null)}');
  print();

  // Turno 4-5: Atacando
  goblin.estadoAtual = Atacando();
  for (int turno = 4; turno <= 5; turno++) {
    print('TURNO $turno: (Em combate direto)');
    print('  Estado: ${goblin.estadoAtual.nome}');
    print('  HP: ${goblin.hpAtual}');
    // Simular dano do jogador
    var dano = 8;
    goblin.sofrerDano(dano);
    print('  [Jogador causa $dano de dano]');
    print('  HP após ataque: ${goblin.hpAtual}');
    print('  Ação: ${goblin.obterProximaAcao(jogador, null)}');
    print();
  }

  // Turno 6: Fugindo (HP baixo)
  print('TURNO 6: (HP abaixo de 30%)');
  goblin.estadoAtual = Fugindo();
  print('  Estado: ${goblin.estadoAtual.nome}');
  print('  HP: ${goblin.hpAtual} (${(goblin.hpAtual / goblin.hpMax * 100).toStringAsFixed(1)}%)');
  print('  Ação: ${goblin.obterProximaAcao(jogador, null)}');
  print();

  // Turno 7: Fugindo (continuação)
  print('TURNO 7: (Continuando fuga)');
  print('  Estado: ${goblin.estadoAtual.nome}');
  print('  HP: ${goblin.hpAtual}');
  print('  Ação: ${goblin.obterProximaAcao(jogador, null)}');
  print();

  // Turno 8: Recuperação e volta para perseguição
  goblin.hpAtual = 25; // Simular cura durante fuga
  print('TURNO 8: (Recuperou alguns HP durante fuga)');
  print('  Estado: ${goblin.estadoAtual.nome}');
  print('  HP: ${goblin.hpAtual} (${(goblin.hpAtual / goblin.hpMax * 100).toStringAsFixed(1)}%)');
  var novoEstado = goblin.estadoAtual.atualizar(goblin, jogador, null);
  if (novoEstado != null) {
    goblin.estadoAtual = novoEstado;
    print('  [Transição para: ${goblin.estadoAtual.nome}]');
  }
  print('  Ação: ${goblin.obterProximaAcao(jogador, null)}');

  print('\n=== FIM DA DEMONSTRAÇÃO ===');
}
