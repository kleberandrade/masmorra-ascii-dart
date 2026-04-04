import 'inimigo.dart';

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          nome: 'Zumbi',
          simbolo: 'Z',
          hp: 8,
          maxHp: 8,
          ataque: 3,
          descricao: 'Uma criatura de decomposição e vontade de carne.',
        );

  @override
  String descreverAcao() {
    return 'O Zumbi grunhe e avança, despedaçando o ar!';
  }
}
