import 'modelos/jogador.dart';
import 'modelos/inimigo.dart';
import 'sistemas/combate.dart';

void main() {
  print('╔═══════════════════════════════════════════╗');
  print('║  MASMORRA ASCII - Step 29: Testes        ║');
  print('║  Testes Unitários com package:test       ║');
  print('╚═══════════════════════════════════════════╝\n');

  // Exemplo de combate
  final jogador = Jogador(
    nome: 'Aragorn',
    hpMax: 50,
    ataque: 10,
    defesa: 2,
  );

  final inimigo = Inimigo(
    nome: 'Goblin',
    hpMax: 20,
    ataque: 3,
    defesa: 0,
  );

  final combate = Combate(jogador: jogador, inimigo: inimigo);

  print('COMBATE: ${jogador.nome} vs ${inimigo.nome}');
  print('${jogador.nome}: HP ${jogador.hpAtual}/${jogador.hpMax}, ATK ${jogador.ataque}');
  print('${inimigo.nome}: HP ${inimigo.hpAtual}/${inimigo.hpMax}, ATK ${inimigo.ataque}\n');

  int turno = 0;
  while (jogador.estaVivo && inimigo.estaVivo && turno < 50) {
    turno++;
    print('--- Turno $turno ---');

    // Turno do jogador
    combate.atacarInimigo();
    print('${jogador.nome} ataca ${inimigo.nome}!');
    print('  ${inimigo.nome} HP: ${inimigo.hpAtual}/${inimigo.hpMax}');

    if (!inimigo.estaVivo) break;

    // Turno do inimigo
    combate.ataqueInimigo();
    print('${inimigo.nome} ataca ${jogador.nome}!');
    print('  ${jogador.nome} HP: ${jogador.hpAtual}/${jogador.hpMax}');

    print('');
  }

  print('=== RESULTADO ===');
  if (jogador.estaVivo) {
    print('Vitória! ${jogador.nome} venceu!');
    jogador.ganharXP(inimigo.xpRecompensa);
    print('${jogador.nome} ganhou ${inimigo.xpRecompensa} XP');
  } else {
    print('Derrota! ${inimigo.nome} venceu!');
  }

  print('\nExecute "dart test" para rodar a suite de testes!');
}
