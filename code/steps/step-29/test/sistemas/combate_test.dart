import 'package:test/test.dart';
import 'package:masmorra_ascii/modelos/jogador.dart';
import 'package:masmorra_ascii/modelos/inimigo.dart';
import 'package:masmorra_ascii/sistemas/combate.dart';

void main() {
  group('CalculadorDano', () {
    late CalculadorDano calc;

    setUp(() {
      calc = CalculadorDano();
    });

    test('dano minimo eh 1', () {
      final dano = calc.calcular(5, 10);
      expect(dano, greaterThanOrEqualTo(1));
    });

    test('ataque maior que defesa causa dano', () {
      final dano = calc.calcular(10, 3);
      expect(dano, greaterThan(0));
    });

    test('defesa maior que ataque causa dano minimo', () {
      final dano = calc.calcular(5, 10);
      expect(dano, equals(1));
    });

    test('dano eh consistente em multiplas chamadas', () {
      final danoCheio = calc.calcular(10, 3);
      expect(danoCheio, greaterThan(6));
      expect(danoCheio, lessThanOrEqualTo(9));
    });
  });

  group('Combate', () {
    late Jogador jogador;
    late Inimigo inimigo;
    late Combate combate;

    setUp(() {
      jogador = Jogador(nome: 'Heroi', hpMax: 50, ataque: 10);
      inimigo = Inimigo(nome: 'Goblin', hpMax: 20, ataque: 3);
      combate = Combate(jogador: jogador, inimigo: inimigo);
    });

    test('combate nao comeca terminado', () {
      expect(combate.terminou, isFalse);
    });

    test('jogador ataca e causa dano', () {
      final hpAntes = inimigo.hpAtual;
      combate.atacarInimigo();
      expect(inimigo.hpAtual, lessThan(hpAntes));
      expect(inimigo.estaVivo, isTrue);
    });

    test('inimigo morre apos dano suficiente', () {
      for (int i = 0; i < 5; i++) {
        combate.atacarInimigo();
        if (!inimigo.estaVivo) break;
      }
      expect(inimigo.estaVivo, isFalse);
      expect(combate.terminou, isTrue);
    });

    test('inimigo ataca e causa dano', () {
      final hpAntes = jogador.hpAtual;
      combate.ataqueInimigo();
      expect(jogador.hpAtual, lessThan(hpAntes));
    });

    test('jogador pode defender', () {
      combate.defender();
      expect(combate.defesa, equals(1));
    });

    test('defender pode ser resetado', () {
      combate.defender();
      combate.resetarDefesa();
      expect(combate.defesa, equals(0));
    });

    test('jogador vence quando inimigo morre', () {
      while (inimigo.estaVivo) {
        combate.atacarInimigo();
      }
      expect(combate.jogadorVenceu(), isTrue);
      expect(combate.inimigoVenceu(), isFalse);
    });

    test('inimigo vence quando jogador morre', () {
      jogador.sofrerDano(100);
      expect(combate.inimigoVenceu(), isTrue);
      expect(combate.jogadorVenceu(), isFalse);
    });

    test('nao pode atacar apos combate terminar', () {
      while (inimigo.estaVivo) {
        combate.atacarInimigo();
      }

      final hpFinal = inimigo.hpAtual;
      combate.atacarInimigo();
      expect(inimigo.hpAtual, equals(hpFinal));
    });

    test('combate pode ser longo e equilibrado', () {
      var jogador2 = Jogador(nome: 'Guerreiro', hpMax: 30, ataque: 5);
      var inimigo2 = Inimigo(nome: 'Lobo', hpMax: 25, ataque: 4);
      var combate2 = Combate(jogador: jogador2, inimigo: inimigo2);

      int turnos = 0;
      while (combate2.jogador.estaVivo &&
          combate2.inimigo.estaVivo &&
          turnos < 100) {
        combate2.atacarInimigo();
        if (combate2.terminou) break;
        combate2.ataqueInimigo();
        turnos++;
      }

      expect(turnos, lessThan(100));
      expect(combate2.terminou, isTrue);
    });
  });
}
