import 'inimigo.dart';

class Lobo extends Inimigo {
  Lobo()
      : super(
          nome: 'Lobo',
          simbolo: 'L',
          hp: 5,
          maxHp: 5,
          ataque: 2,
          descricao: 'Uma criatura selvagem de garras afiadas.',
        );

  @override
  String descreverAcao() {
    return 'O Lobo rosna ameaçadoramente, dentes à mostra.';
  }
}
