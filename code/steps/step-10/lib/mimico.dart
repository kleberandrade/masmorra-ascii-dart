import 'inimigo.dart';

/// Inimigo “mímico” (nome acentuado só na narrativa, não no identificador Dart).
class Mimico extends Inimigo {
  Mimico()
      : super(
          nome: 'Mímico',
          simbolo: 'M',
          hp: 12,
          maxHp: 12,
          ataque: 5,
          descricao: 'Um baú vivo. Nem todo tesouro é o que parece.',
        );

  @override
  String descreverAcao() {
    return 'O baú se abre de repente! Garras saem de suas laterais!';
  }
}
