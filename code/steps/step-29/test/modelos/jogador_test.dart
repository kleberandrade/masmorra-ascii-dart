import 'package:test/test.dart';
import 'package:masmorra_ascii/modelos/jogador.dart';

void main() {
  group('Jogador', () {
    late Jogador jogador;

    setUp(() {
      jogador = Jogador(
        nome: 'Aragorn',
        hpMax: 50,
        ataque: 5,
        defesa: 1,
      );
    });

    test('construir jogador com atributos', () {
      expect(jogador.nome, equals('Aragorn'));
      expect(jogador.hpMax, equals(50));
      expect(jogador.hpAtual, equals(50));
      expect(jogador.ataque, equals(5));
      expect(jogador.defesa, equals(1));
      expect(jogador.nivel, equals(1));
      expect(jogador.xp, equals(0));
    });

    test('jogador comeca vivo', () {
      expect(jogador.estaVivo, isTrue);
    });

    test('sofrer dano reduz HP', () {
      jogador.sofrerDano(10);
      expect(jogador.hpAtual, equals(40));
      expect(jogador.estaVivo, isTrue);
    });

    test('sofrer dano critico mata', () {
      jogador.sofrerDano(100);
      expect(jogador.hpAtual, equals(0));
      expect(jogador.estaVivo, isFalse);
    });

    test('HP nao pode ser negativo', () {
      jogador.sofrerDano(60);
      expect(jogador.hpAtual, equals(0));
      expect(jogador.hpAtual, isNot(lessThan(0)));
    });

    test('curar aumenta HP', () {
      jogador.sofrerDano(20);
      jogador.curar(10);
      expect(jogador.hpAtual, equals(40));
    });

    test('curar nao ultrapassa HP maximo', () {
      jogador.curar(100);
      expect(jogador.hpAtual, equals(jogador.hpMax));
    });

    test('ganhar XP acumula total', () {
      jogador.ganharXP(50);
      expect(jogador.xp, equals(50));

      jogador.ganharXP(30);
      expect(jogador.xp, equals(80));
    });

    test('nao pode ganhar XP negativo', () {
      jogador.ganharXP(-50);
      expect(jogador.xp, equals(0));
    });

    test('ganhar 100 XP sobe de nivel', () {
      jogador.ganharXP(100);
      expect(jogador.nivel, equals(2));
    });

    test('subir de nivel aumenta HP', () {
      final hpAntes = jogador.hpMax;
      jogador.ganharXP(100);
      expect(jogador.hpMax, greaterThan(hpAntes));
    });

    test('adicionar item ao inventario', () {
      jogador.adicionarItem('Espada');
      expect(jogador.inventario, contains('Espada'));
      expect(jogador.inventario.length, equals(1));
    });

    test('remover item do inventario', () {
      jogador.adicionarItem('Pocao');
      final removido = jogador.removerItem('Pocao');
      expect(removido, isTrue);
      expect(jogador.inventario, isEmpty);
    });

    test('remover item inexistente retorna false', () {
      final removido = jogador.removerItem('Inexistente');
      expect(removido, isFalse);
    });
  });
}
