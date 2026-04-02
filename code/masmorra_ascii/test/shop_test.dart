import 'package:masmorra_ascii/masmorra_ascii.dart';
import 'package:masmorra_ascii/src/economy/shop.dart';
import 'package:test/test.dart';

void main() {
  group('tentarVender', () {
    test('larga arma equipada ao vender o mesmo item', () {
      final w = Weapon(id: 'x', nome: 'Teste', dano: 3, preco: 10);
      final j = Player(name: 'p');
      j.inventario.add(w);
      j.equiparArmaPorId('x');
      expect(j.armaEquipada, isNotNull);
      expect(tentarVender(j, 0), isTrue);
      expect(j.armaEquipada, isNull);
    });
  });
}
