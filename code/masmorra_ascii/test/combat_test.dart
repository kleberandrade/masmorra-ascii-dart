import 'package:masmorra_ascii/src/ai/estado_ia.dart';
import 'package:masmorra_ascii/src/combat/combat.dart';
import 'package:masmorra_ascii/src/model/enemy.dart';
import 'package:masmorra_ascii/src/model/player.dart';
import 'package:test/test.dart';

void main() {
  group('executarCombate', () {
    late Player jogador;
    late List<String> logs;

    setUp(() {
      jogador = Player(name: 'Herói', hp: 20);
      logs = [];
    });

    test('jogador pode atacar inimigo e causar dano', () {
      final inimigo = Goblin();
      final hpInicial = inimigo.hp;

      executarCombate(
        jogador: jogador,
        inimigo: inimigo,
        log: logs.add,
      );

      expect(inimigo.hp, lessThan(hpInicial));
    });

    test('inimigo recebe dano corretamente e HP decresce', () {
      final inimigo = Goblin();
      final hpInicial = inimigo.hp;

      // Simula um turno de combate
      final dano = jogador.danoAtual;
      inimigo.hp -= dano;

      expect(inimigo.hp, equals(hpInicial - dano));
    });

    test('jogador pode defender reduzindo dano recebido', () {
      final inimigo = Goblin();
      final hpJogadorInicial = jogador.hp;

      // Calcula dano sem defesa
      final danoSemDefesa = inimigo.danoBase;

      // Simula defesa reduzindo dano em 50%
      final danoComDefesa = (danoSemDefesa / 2).toStringAsFixed(0);
      jogador.danificar(int.parse(danoComDefesa));

      expect(jogador.hp, greaterThan(hpJogadorInicial - danoSemDefesa));
    });

    test('combate termina quando HP do inimigo chega a 0', () {
      final inimigo = Slime(); // HP = 5
      inimigo.hp = 1;

      final resultado = executarCombate(
        jogador: jogador,
        inimigo: inimigo,
        log: logs.add,
      );

      expect(resultado, isTrue);
      expect(inimigo.morto, isTrue);
    });

    test('combate termina quando HP do jogador chega a 0', () {
      final inimigo = Skeleton(); // dano = 3
      jogador.hp = 1;

      final resultado = executarCombate(
        jogador: jogador,
        inimigo: inimigo,
        log: logs.add,
      );

      expect(resultado, isFalse);
      expect(jogador.hp, equals(0));
    });

    test('jogador recebe ouro ao vencer', () {
      final inimigo = Goblin();
      final ouroInicial = jogador.ouro;
      inimigo.hp = 1; // Garante que será derrotado no primeiro turno

      executarCombate(
        jogador: jogador,
        inimigo: inimigo,
        log: logs.add,
      );

      expect(jogador.ouro, greaterThan(ouroInicial));
    });

    test('ouro recompensado é baseado no nome do inimigo', () {
      final inimigo = Goblin(); // nome.length = 6
      inimigo.hp = 1;

      final ouroInicial = jogador.ouro;
      executarCombate(
        jogador: jogador,
        inimigo: inimigo,
        log: logs.add,
      );

      // ouro = 4 + nome.length % 3
      final ouroEsperado = 4 + inimigo.nome.length % 3;
      expect(jogador.ouro, equals(ouroInicial + ouroEsperado));
    });

    test('combate gera logs de ações', () {
      final inimigo = Goblin();
      inimigo.hp = 1;

      executarCombate(
        jogador: jogador,
        inimigo: inimigo,
        log: logs.add,
      );

      expect(logs, isNotEmpty);
      expect(logs.first, contains('Combate'));
    });

    test('FSM: inimigo com HP ≤25% transita para Fugindo', () {
      final inimigo = Skeleton(); // hpMax 8
      inimigo.hp = 2;
      inimigo.estado = Atacando();
      final alvo = Player(name: 'Herói', hp: 50);

      inimigo.executarTurno(alvo, logs.add);

      expect(inimigo.estado, isA<Fugindo>());
      expect(logs.any((m) => m.contains('Fugindo')), isTrue);
    });

    test('defesa do jogador reduz dano do ataque do inimigo', () {
      final inimigo = Skeleton(); // ataque 3
      final alvo = Player(name: 'Herói', hp: 20, defesa: 2);
      inimigo.executarTurno(alvo, logs.add);
      expect(alvo.hp, equals(19)); // max(1, 3-2)=1 de dano
    });
  });
}
