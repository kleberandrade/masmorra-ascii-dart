import 'package:test/test.dart';
import 'package:masmorra_ascii/modelos/inimigo.dart';

void main() {
  group('Inimigo', () {
    late Inimigo inimigo;

    setUp(() {
      inimigo = Inimigo(
        nome: 'Goblin',
        hpMax: 20,
        ataque: 3,
        defesa: 0,
        xpRecompensa: 50,
        ouroRecompensa: 25,
      );
    });

    test('construir inimigo com atributos', () {
      expect(inimigo.nome, equals('Goblin'));
      expect(inimigo.hpMax, equals(20));
      expect(inimigo.hpAtual, equals(20));
      expect(inimigo.ataque, equals(3));
      expect(inimigo.defesa, equals(0));
      expect(inimigo.xpRecompensa, equals(50));
      expect(inimigo.ouroRecompensa, equals(25));
    });

    test('inimigo comeca vivo', () {
      expect(inimigo.estaVivo, isTrue);
    });

    test('sofrer dano reduz HP', () {
      inimigo.sofrerDano(5);
      expect(inimigo.hpAtual, equals(15));
      expect(inimigo.estaVivo, isTrue);
    });

    test('sofrer dano critico mata', () {
      inimigo.sofrerDano(30);
      expect(inimigo.hpAtual, equals(0));
      expect(inimigo.estaVivo, isFalse);
    });

    test('HP nao pode ser negativo', () {
      inimigo.sofrerDano(100);
      expect(inimigo.hpAtual, equals(0));
      expect(inimigo.hpAtual, isNot(lessThan(0)));
    });

    test('curar aumenta HP', () {
      inimigo.sofrerDano(10);
      inimigo.curar(5);
      expect(inimigo.hpAtual, equals(15));
    });

    test('curar nao ultrapassa HP maximo', () {
      inimigo.sofrerDano(5);
      inimigo.curar(20);
      expect(inimigo.hpAtual, equals(inimigo.hpMax));
    });

    test('aumentar ataque aumenta valor', () {
      final ataqueAntes = inimigo.ataque;
      inimigo.aumentarAtaque(2);
      expect(inimigo.ataque, equals(ataqueAntes + 2));
    });

    test('aumentar ataque negativo nao faz nada', () {
      final ataqueAntes = inimigo.ataque;
      inimigo.aumentarAtaque(-5);
      expect(inimigo.ataque, equals(ataqueAntes));
    });

    test('inimigo morto pode ser curado', () {
      inimigo.sofrerDano(30);
      expect(inimigo.estaVivo, isFalse);
      inimigo.curar(10);
      expect(inimigo.hpAtual, equals(10));
      expect(inimigo.estaVivo, isTrue);
    });
  });
}
