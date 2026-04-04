import 'entidade.dart';

class Inimigo extends Entidade {
  int hpMax;
  int hpAtual;

  Inimigo({
    required String nome,
    required int x,
    required int y,
    required this.hpMax,
    required String simbolo,
  })  : hpAtual = hpMax,
        super(
          x: x,
          y: y,
          simbolo: simbolo,
          nome: nome,
        );
}
