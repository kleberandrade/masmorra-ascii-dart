import 'inimigo.dart';

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          nome: 'Esqueleto',
          simbolo: 'E',
          hp: 15,
          maxHp: 15,
          ataque: 4,
          descricao: 'Ossos antigos, alma presa. Rangem com cada passo.',
        );

  @override
  String descreverAcao() {
    return 'O Esqueleto levanta o braço ósseo, você sente o frio da morte.';
  }
}
